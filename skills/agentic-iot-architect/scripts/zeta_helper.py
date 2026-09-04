#!/usr/bin/env python3
"""
ZETA API Helper Script for Agentic IoT Architect Skill
Provides utilities for ZETA HTTP HMAC-SHA1 signature generation, MQTT topic validation, and payload structure verification.
"""

import hmac
import hashlib
import time
import re
import json
import argparse

def generate_zeta_signature(api_key: str, secret_key: str, request_time: int = None) -> dict:
    """
    Generates HMAC-SHA1 signature for ZETA HTTP API getWanAccessToken endpoint.
    
    Sign logic:
    Content to sign: api_key
    Sign key: secret_key + str(request_time)
    Signature algorithm: HMAC-SHA1
    """
    if request_time is None:
        request_time = int(time.time())
        
    sign_key = f"{secret_key}{request_time}".encode('utf-8')
    content = api_key.encode('utf-8')
    
    signature = hmac.new(sign_key, content, hashlib.sha1).hexdigest()
    
    query_params = f"api_key={api_key}&signal={signature}&request_time={request_time}"
    endpoint = f"/teamcms/ws/auth_v2/auth_token/query/getWanAccessToken?{query_params}"
    
    return {
        "api_key": api_key,
        "request_time": request_time,
        "signature": signature,
        "query_params": query_params,
        "endpoint": endpoint
    }

def validate_mqtt_topic(topic: str) -> dict:
    """
    Validates ZETA MQTT topic format: api_key/version/opType/uid/msgType
    """
    parts = topic.split('/')
    if len(parts) < 4:
        return {"valid": False, "reason": "Topic has fewer than 4 levels"}
        
    api_key = parts[0]
    version = parts[1]
    op_type = parts[2]
    uid = parts[3]
    msg_type = "/".join(parts[4:]) if len(parts) > 4 else ""
    
    valid_op_types = ["ms", "mote", "ap", "upgrade"]
    is_op_valid = any(op_type.startswith(ot) or op_type in valid_op_types for ot in valid_op_types)
    
    return {
        "valid": is_op_valid,
        "api_key": api_key,
        "version": version,
        "op_type": op_type,
        "uid": uid,
        "msg_type": msg_type
    }

def validate_zeta_response(data: dict) -> dict:
    """
    Validates standard ZETA HTTP response JSON format.
    Standard ZETA Response:
    { "status": 0, "errmsg": "", "data": [...], "ts": 175907811 }
    """
    if not isinstance(data, dict):
        return {"valid": False, "error": "Response must be a JSON object"}
        
    has_status = "status" in data
    has_data = "data" in data
    status = data.get("status")
    errmsg = data.get("errmsg", "")
    
    return {
        "valid": has_status and has_data,
        "success": status == 0,
        "status_code": status,
        "errmsg": errmsg,
        "data_count": len(data.get("data", [])) if isinstance(data.get("data"), list) else None
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ZETA API Helper CLI")
    parser.add_argument("--action", choices=["sign", "topic", "check_payload"], required=True)
    parser.add_argument("--api-key", type=str, help="ZETA Enterprise API Key")
    parser.add_argument("--secret-key", type=str, help="ZETA Enterprise Secret Key")
    parser.add_argument("--topic", type=str, help="MQTT Topic to validate")
    
    args = parser.parse_args()
    
    if args.action == "sign":
        if not args.api_key or not args.secret_key:
            print("Error: --api-key and --secret-key required for sign action.")
            exit(1)
        res = generate_zeta_signature(args.api_key, args.secret_key)
        print(json.dumps(res, indent=2))
    elif args.action == "topic":
        if not args.topic:
            print("Error: --topic required for topic action.")
            exit(1)
        res = validate_mqtt_topic(args.topic)
        print(json.dumps(res, indent=2))
