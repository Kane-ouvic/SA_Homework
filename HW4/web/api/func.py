import os

def split_string_xor(read_bytes, n, padding_char=b'\x00'):
    # 計算字串長度及每段的理論大小
    L = len(read_bytes)
    quotient = L // (n-1)
    remainder = L % (n-1)
    
    split_lengths = []
    
    
    if(remainder == 0):
        first_length = quotient
    else:
        first_length = quotient + 1
    second_length = quotient
    
    for i in range(n-1):
        if i < remainder:
            split_lengths.append(first_length)
        else:
            split_lengths.append(second_length)
    
    # 切割字串成 N-1 段
    splitted_strings = []
    start_index = 0
    for length in split_lengths:
        end_index = start_index + length
        substring = read_bytes[start_index:end_index]
        if len(substring) < first_length:
            substring += padding_char

        splitted_strings.append(substring)
        start_index = end_index

    # # 計算前 N-1 個字串的 XOR 結果
    xor_result = b'\x00' * first_length
    for s in splitted_strings:
        xor_result = bytes([a ^ b for a, b in zip(xor_result, s)])
    splitted_strings.append(xor_result)

    return splitted_strings


def get_file_size(directory, filename):
    filepath = os.path.join(directory, filename)
    if os.path.exists(filepath):
        size = os.path.getsize(filepath)
        return size
    else:
        return None