import json
import base64
import os
import sys

# 加密密钥
# 注意：必须与 Dart 代码中的 _encryptionKey 保持完全一致
# Dart: 'YOUR_ENCRYPTION_KEY_HERE_24CH' (确保完全匹配)
# TODO: 请替换为你自己的密钥（至少 24 个字符）
KEY = "YOUR_ENCRYPTION_KEY_HERE_24CH"

def encrypt(plain_text):
    """
    使用 XOR + Base64 进行加密
    """
    # 将密钥和明文转换为字节
    key_bytes = KEY.encode('utf-8')
    plain_bytes = plain_text.encode('utf-8')
    
    # 结果字节数组
    encrypted_bytes = bytearray(len(plain_bytes))
    
    # XOR 运算
    for i in range(len(plain_bytes)):
        encrypted_bytes[i] = plain_bytes[i] ^ key_bytes[i % len(key_bytes)]
        
    # Base64 编码
    return base64.b64encode(encrypted_bytes).decode('utf-8')

def decrypt(encrypted_text):
    """
    解密 (用于验证)
    """
    key_bytes = KEY.encode('utf-8')
    try:
        encrypted_bytes = base64.b64decode(encrypted_text)
    except Exception as e:
        print(f"Base64 解码失败: {e}")
        return None

    decrypted_bytes = bytearray(len(encrypted_bytes))
    
    for i in range(len(encrypted_bytes)):
        decrypted_bytes[i] = encrypted_bytes[i] ^ key_bytes[i % len(key_bytes)]
        
    return decrypted_bytes.decode('utf-8')

def main():
    input_file = 'release_config_plaintext.json'
    output_file = 'release_config.json'
    
    # 检查输入文件是否存在
    if not os.path.exists(input_file):
        print(f"错误: 找不到输入文件 {input_file}")
        return

    try:
        # 读取明文配置
        print(f"正在读取 {input_file} ...")
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # 验证 JSON 格式
        try:
            json.loads(content)
        except json.JSONDecodeError as e:
            print(f"错误: {input_file} 不是有效的 JSON 格式")
            print(e)
            return

        # 加密
        print("正在加密...")
        encrypted_content = encrypt(content)
        
        # 写入加密文件
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(encrypted_content)
            
        print(f"✅ 加密成功!")
        print(f"📁 已保存到: {output_file}")
        print("-" * 30)
        print("📋 请将该文件内容上传到 OSS 作为 release_config.json")
        print("-" * 30)
        
        # 验证
        print("正在验证加密结果...")
        decrypted_content = decrypt(encrypted_content)
        if decrypted_content == content:
            print("✅ 验证通过：解密后内容与原文一致")
        else:
            print("❌ 验证失败：解密后内容不匹配！")

    except Exception as e:
        print(f"发生异常: {e}")

if __name__ == "__main__":
    main()
