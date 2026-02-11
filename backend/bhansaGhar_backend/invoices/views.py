from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, IsAuthenticated
from rest_framework.request import Request
from django.shortcuts import get_object_or_404
from django.utils import timezone
from typing import Type, cast
from django.db.models import QuerySet

from .models import Invoice
from .serializers import (
    InvoiceSerializer,
    InvoiceDetailSerializer,
    InvoiceCloseSerializer,
    InvoiceListSerializer
)
from .permissions import IsAdminOrWaiter, CanCloseInvoice, CanViewInvoice
from restaurants.models import Restaurant


class InvoiceViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Invoice management
    
    Endpoints:
    - GET /api/invoices/ - List all invoices (admin only)
    - GET /api/invoices/{id}/ - Get invoice details
    - POST /api/invoices/{id}/close-table/ - Close invoice (admin/waiter)
    - POST /api/invoices/{id}/mark-paid/ - Mark as paid
    - GET /api/restaurants/{restaurant_id}/invoices/ - Get restaurant invoices
    - GET /api/restaurants/{restaurant_id}/tables/{table_id}/current-invoice/ - Get current table invoice
    """
    
    serializer_class = InvoiceDetailSerializer
    queryset = Invoice.objects.all()
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get_serializer_class(self) -> Type:
        if self.action in ['list']:
            return InvoiceListSerializer
        elif self.action in ['retrieve']:
            return InvoiceDetailSerializer
        elif self.action in ['close_table', 'mark_paid']:
            return InvoiceCloseSerializer
        return InvoiceDetailSerializer
    
    def get_queryset(self):  # type: ignore[override]
        queryset = Invoice.objects.all()
        
        # Type cast request to DRF Request for query_params access
        request = cast(Request, self.request)
        
        # Filter by restaurant if provided
        restaurant_id = request.query_params.get('restaurant_id')
        if restaurant_id:
            queryset = queryset.filter(restaurant_id=restaurant_id)
        
        # Filter by status
        status_filter = request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        # Filter by date range
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        if start_date:
            queryset = queryset.filter(created_at__gte=start_date)
        if end_date:
            queryset = queryset.filter(created_at__lte=end_date)
        
        return queryset.order_by('-created_at')
    
    def retrieve(self, request: Request, *args, **kwargs) -> Response:
        """Get invoice details"""
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def close_table(self, request: Request, pk=None) -> Response:
        """
        Close table - expire invoice (Manual control)
        
        POST /api/invoices/{id}/close-table/
        {
            "reason": "waiter_cleared" | "customer_left" | "admin_closed"
        }
        
        Only admin/waiter can close
        """
        invoice = self.get_object()
        
        # Check permissions
        if not invoice.can_close(request.user):
            return Response(
                {'error': 'You do not have permission to close this invoice'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Check status
        if invoice.status == 'expired':
            return Response(
                {'error': 'Invoice already closed'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if invoice.status == 'paid':
            return Response(
                {'error': 'Cannot close a paid invoice'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get reason
        serializer = InvoiceCloseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reason = serializer.validated_data['reason']
        
        # Close the invoice
        invoice.close_table(closed_by=request.user, reason=reason)
        
        return Response(
            {
                'message': f'Table {invoice.table_number} closed',
                'invoice': InvoiceDetailSerializer(invoice, context={'request': request}).data
            },
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def mark_paid(self, request: Request, pk=None) -> Response:
        """
        Mark invoice as paid
        
        POST /api/invoices/{id}/mark-paid/
        """
        invoice = self.get_object()
        
        # Only admin/waiter/customer can mark as paid
        if not (request.user.is_staff or request.user.is_superuser):
            return Response(
                {'error': 'Only admin or waiter can mark as paid'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if invoice.status not in ['open', 'ready']:
            return Response(
                {'error': f'Cannot mark {invoice.status} invoice as paid'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        invoice.mark_paid()
        
        return Response(
            {
                'message': 'Invoice marked as paid',
                'invoice': InvoiceDetailSerializer(invoice, context={'request': request}).data
            },
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'])
    def by_restaurant(self, request: Request) -> Response:
        """
        Get all invoices for a restaurant
        
        GET /api/invoices/by_restaurant/?restaurant_id={id}&status={status}
        """
        restaurant_id = request.query_params.get('restaurant_id')
        
        if not restaurant_id:
            return Response(
                {'error': 'restaurant_id query parameter required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        invoices = self.get_queryset().filter(restaurant_id=restaurant_id)
        
        page = self.paginate_queryset(invoices)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(invoices, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def current_table_invoice(self, request: Request) -> Response:
        """
        Get current OPEN invoice for a table
        
        GET /api/invoices/current_table_invoice/?restaurant_id={id}&table_id={id}
        """
        restaurant_id = request.query_params.get('restaurant_id')
        table_id = request.query_params.get('table_id')
        
        if not restaurant_id or not table_id:
            return Response(
                {'error': 'restaurant_id and table_id query parameters required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        invoice = Invoice.objects.filter(
            restaurant_id=restaurant_id,
            table_number=table_id,
            status__in=['open', 'ready']
        ).first()
        
        if not invoice:
            return Response(
                {'message': 'No open invoice for this table'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = InvoiceDetailSerializer(invoice, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def analytics(self, request: Request) -> Response:
        """
        Get invoice analytics for a restaurant
        
        GET /api/invoices/analytics/?restaurant_id={id}&period=today|week|month
        """
        restaurant_id = request.query_params.get('restaurant_id')
        period = request.query_params.get('period', 'today')
        
        if not restaurant_id:
            return Response(
                {'error': 'restaurant_id query parameter required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        from django.utils.timezone import now
        from datetime import timedelta
        
        if period == 'today':
            start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
        elif period == 'week':
            start = timezone.now() - timedelta(days=7)
        elif period == 'month':
            start = timezone.now() - timedelta(days=30)
        else:
            start = timezone.now() - timedelta(days=7)
        
        invoices = Invoice.objects.filter(
            restaurant_id=restaurant_id,
            created_at__gte=start,
            status__in=['paid', 'open', 'ready']
        )
        
        total_revenue = sum(float(inv.total) for inv in invoices if inv.status == 'paid')
        total_open = sum(float(inv.total) for inv in invoices if inv.status in ['open', 'ready'])
        
        return Response({
            'period': period,
            'total_invoices': invoices.count(),
            'paid_invoices': invoices.filter(status='paid').count(),
            'open_invoices': invoices.filter(status__in=['open', 'ready']).count(),
            'total_revenue': round(total_revenue, 2),
            'pending_revenue': round(total_open, 2),
            'average_bill': round(total_revenue / max(invoices.filter(status='paid').count(), 1), 2),
        })
