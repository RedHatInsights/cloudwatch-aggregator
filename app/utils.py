def truthy_string(str):
    if str:
        return str.lower() in ("true", "1")
    else:
        return False
