package com.shopcloud.checkout.invoice;

import java.math.BigDecimal;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import com.shopcloud.checkout.order.CustomerOrder;
import com.shopcloud.checkout.order.OrderLine;

import io.awspring.cloud.sqs.operations.SendResult;
import io.awspring.cloud.sqs.operations.SqsTemplate;

@Component
public class InvoicePublisher {

    private static final Logger log = LoggerFactory.getLogger(InvoicePublisher.class);

    private final SqsTemplate sqsTemplate;
    private final String invoiceQueueUrl;

    public InvoicePublisher(
            SqsTemplate sqsTemplate,
            @Value("${shopcloud.invoice.queue-url}") String invoiceQueueUrl
    ) {
        this.sqsTemplate = sqsTemplate;
        this.invoiceQueueUrl = invoiceQueueUrl;
    }

    public void publishInvoiceRequested(CustomerOrder order, String customerEmail) {
        if (!StringUtils.hasText(invoiceQueueUrl)) {
            log.warn(
                    "Invoice queue URL is not configured. Skipping invoice event for orderId={}",
                    order.getId()
            );
            return;
        }

        InvoiceRequestedEvent event = buildInvoiceEvent(order, customerEmail);

        try {
            SendResult<InvoiceRequestedEvent> result = sqsTemplate.send(invoiceQueueUrl, event);

            log.info(
                    "Invoice event sent to SQS. orderId={} messageId={} queue={}",
                    order.getId(),
                    result.messageId(),
                    invoiceQueueUrl
            );
        } catch (Exception ex) {
            /*
             * We do not throw the exception here.
             *
             * Reason:
             * The order is already confirmed, stock was already decreased,
             * and the cart was already cleared.
             *
             * If invoice publishing fails, checkout should still return success.
             * The failed invoice event should be visible in logs/CloudWatch.
             *
             * A stronger production design would use a transactional outbox table,
             * but this is the simple version for your project.
             */
            log.error(
                    "Failed to send invoice event to SQS. orderId={} email={}",
                    order.getId(),
                    customerEmail,
                    ex
            );
        }
    }

    private InvoiceRequestedEvent buildInvoiceEvent(CustomerOrder order, String customerEmail) {
        List<InvoiceItemEvent> itemEvents = order.getItems()
                .stream()
                .map(this::toInvoiceItemEvent)
                .toList();

        return new InvoiceRequestedEvent(
                order.getId(),
                order.getUserId(),
                customerEmail,
                order.getTotalAmount(),
                "USD",
                order.getCreatedAt(),
                itemEvents
        );
    }

    private InvoiceItemEvent toInvoiceItemEvent(OrderLine item) {
        BigDecimal lineTotal = item.getUnitPrice()
                .multiply(BigDecimal.valueOf(item.getQuantity()));

        return new InvoiceItemEvent(
                item.getProductId(),
                item.getProductName(),
                item.getQuantity(),
                item.getUnitPrice(),
                lineTotal
        );
    }
}