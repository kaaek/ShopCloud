import json
import os
import boto3
from datetime import datetime, timezone
from email.message import EmailMessage

s3 = boto3.client("s3")
ses = boto3.client("ses")


def lambda_handler(event, context):
    bucket = os.environ["INVOICE_BUCKET"]
    sender = os.environ["SES_SENDER_EMAIL"]

    for record in event.get("Records", []):
        payload = json.loads(record.get("body", "{}"))
        order_id = str(payload.get("orderId", "unknown"))
        customer_email = payload.get("customerEmail")

        invoice_body = json.dumps(
            {
                "invoiceType": "shopcloud-demo-invoice",
                "order": payload,
                "generatedAt": datetime.now(timezone.utc).isoformat(),
            },
            indent=2,
        ).encode("utf-8")

        key = f"invoices/{order_id}.json"
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=invoice_body,
            ContentType="application/json",
        )

        if customer_email:
            msg = EmailMessage()
            msg["Subject"] = f"Your ShopCloud invoice for order {order_id}"
            msg["From"] = sender
            msg["To"] = customer_email
            msg.set_content(
                f"Your invoice for order {order_id} was generated and stored at s3://{bucket}/{key}."
            )

            ses.send_raw_email(
                Source=sender,
                Destinations=[customer_email],
                RawMessage={"Data": msg.as_bytes()},
            )

    return {"statusCode": 200, "body": "processed"}
