package com.shopcloud.checkout.invoice;

import com.shopcloud.checkout.order.CustomerOrder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class InvoicePublisher {

    private static final Logger log = LoggerFactory.getLogger(InvoicePublisher.class);

    public void publishInvoiceRequested(CustomerOrder order, String customerEmail) {
        // Later, replace this with SQS publishing.
        // Keep it as a local placeholder so this app code has no infrastructure dependency.
        log.info("INVOICE_REQUESTED orderId={} userId={} email={}",
                order.getId(), order.getUserId(), customerEmail);
    }
}
