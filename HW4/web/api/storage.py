import base64
import hashlib
import sys
from pathlib import Path
from typing import List
import os

import schemas
from config import settings
from fastapi import UploadFile
from loguru import logger
from func import *
import subprocess

# filename_list = {}

class Storage:
    def __init__(self, is_test: bool):     
        self.block_path: List[Path] = [
            Path("/var/raid") / f"{settings.FOLDER_PREFIX}-{i}-test"
            if is_test
            else Path(settings.UPLOAD_PATH) / f"{settings.FOLDER_PREFIX}-{i}"
            for i in range(settings.NUM_DISKS)
        ]
        self.__create_block()

    def __create_block(self):
        print(self.block_path)
        print(self.block_path)
        print(self.block_path)
        for path in self.block_path:
            logger.warning(f"Creating folder: {path}")
            path.mkdir(parents=True, exist_ok=True)
            path.chmod(0o777)
        filedir = Path("/tmp/filename_list")
        filedir.mkdir(parents=True, exist_ok=True)
        filedir.chmod(0o777)

    async def file_integrity(self, filename: str) -> bool:
        """TODO: check if file integrity is valid
        file integrated must satisfy following conditions:
            1. all data blocks must exist
            2. size of all data blocks must be equal
            3. parity block must exist
            4. parity verify must success

        if one of the above conditions is not satisfied
        the file does not exist
        and the file is considered to be damaged
        so we need to delete the file
        """
        check_blocks_bytes = []
        check_block_string = []
        calculate_xor_bytes = bytes()
        check_xor_bytes = bytes()
        
        
        # 1. all data blocks must exist
        for i in range(settings.NUM_DISKS):
            file_path = f"{self.block_path[i]}"
            file_size = get_file_size(file_path, filename)
            check_blocks_bytes.append(file_size)
            cmd = f"cat {file_path}/{filename}"
            result = subprocess.run(cmd, shell=True, capture_output=True)
            result_bytes = result.stdout
            # print(result_bytes)
            check_block_string.append(result_bytes)
            if file_size is not None:
                print(f"檔案存在，大小為 {file_size} bytes")
            else:
                print("檔案不存在")
                return False
                
        # 2. size of all data blocks must be equal
        # print(check_blocks_bytes)
        for i in range(settings.NUM_DISKS - 1):
            if check_blocks_bytes[i] != check_blocks_bytes[i+1]:
                print("檔案大小不一致")
                return False
        
        check_xor_bytes = check_block_string[-1]
        check_block_string = check_block_string[:-1]
        
        # print(check_blocks_bytes)
        # print(check_xor_string)
        # print(check_block_string)
        # print(check_blocks_bytes)
        # check xor result
        
        convert_bytes_num = len(check_block_string[0])
        xor_result = b'\x00' * convert_bytes_num
        for s in check_block_string:
            xor_result = bytes([a ^ b for a, b in zip(xor_result, s)])
        # print(xor_result)
        # print(convert_bytes_num)
        # calculate_xor_string = xor_result.to_bytes(convert_bytes_num, 'big').decode()
        # print(calculate_xor_string)
        
        if xor_result != check_xor_bytes:
            return False
        else:
            print("檔案完整")
        
        return True

    async def create_file(self, file: UploadFile) -> schemas.File:
        # TODO: create file with data block and parity block and return it's schema

        read_bytes = await file.read()
        file_name = file.filename
        file_content_type = file.content_type
        insert_blocks = split_string_xor(read_bytes, settings.NUM_DISKS)
        
        # split file into n blocks
        
        # create file in block
        for path in self.block_path:
            print(f"create_file: {path}")
            myfile = Path(path) / file.filename
            myfile.touch()
            os.chmod(myfile, 0o777)
            filename_combined = file.filename + ".log"
            myfile = Path("/tmp/filename_list") / filename_combined
            myfile.touch()
            os.chmod(myfile, 0o777)
        
        for i in range(settings.NUM_DISKS):
            file_path = f"{self.block_path[i]}/{file_name}"
            file = open(file_path, "wb")
            file.write(insert_blocks[i])
            file_path = f"/tmp/filename_list/{file_name}.log"
            file = open(file_path, "w")
            file.write(str(len(read_bytes)))
        
        return schemas.File(
            name=file_name,
            size=len(read_bytes),
            checksum=hashlib.md5(read_bytes).hexdigest(),
            content=base64.b64encode(read_bytes),
            content_type=file_content_type,
        )

    async def retrieve_file(self, filename: str) -> bytes:
        # TODO: retrieve the binary data of file
        option = False;
        result_byte = bytes()
        file_path = f"/tmp/filename_list/{filename}.log"
        real_bytes = 0
        try:
            file_log = open(file_path, 'r')
            content = file_log.read()
            file_log.close()
            real_bytes = int(content)
            option = True
        except:
            print("error")
        
        # print(content)
        print(option)
        
        
        for i in range(settings.NUM_DISKS-1):
            file_path = f"{self.block_path[i]}/{filename}"
            cmd = f"cat {file_path}"
            result = subprocess.run(cmd, shell=True, capture_output=True)
            retrieve_bytearray = bytearray(result.stdout)
            if option:
                if i >= real_bytes % (settings.NUM_DISKS-1) and real_bytes % (settings.NUM_DISKS-1) != 0:
                    try:
                        del retrieve_bytearray[-1]
                    except:
                        print("error")
            else:
                if retrieve_bytearray[-1] == 0:
                    try:
                        del retrieve_bytearray[-1]
                    except:
                        print("error")
            retrieve_bytes = bytes(retrieve_bytearray)
            result_byte += retrieve_bytes
        
        return result_byte
        

        # return b"".join("m3ow".encode() for _ in range(100))

    async def update_file(self, file: UploadFile) -> schemas.File:
        # TODO: update file's data block and parity block and return it's schema
        
        # delete
        for path in self.block_path:
            print(f"remove_file: {path}")
            myfile = Path(path) / file.filename
            os.remove(myfile)
            
        
        read_bytes = await file.read()
        file_name = file.filename
        file_content_type = file.content_type
        insert_blocks = split_string_xor(read_bytes, settings.NUM_DISKS)
        for path in self.block_path:
            print(f"create_file: {path}")
            myfile = Path(path) / file.filename
            myfile.touch()
            os.chmod(myfile, 0o777)
            filename_combined = file.filename + ".log"
            myfile = Path("/tmp/filename_list") / filename_combined
            myfile.touch()
            os.chmod(myfile, 0o777)
        
        for i in range(settings.NUM_DISKS):
            file_path = f"{self.block_path[i]}/{file_name}"
            file = open(file_path, "wb")
            file.write(insert_blocks[i])
            file_path = f"/tmp/filename_list/{file_name}.log"
            file = open(file_path, "w")
            file.write(str(len(read_bytes)))

        return schemas.File(
            name=file_name,
            size=len(read_bytes),
            checksum=hashlib.md5(read_bytes).hexdigest(),
            content=base64.b64encode(read_bytes),
            content_type=file_content_type,
        )

    async def delete_file(self, filename: str) -> None:
        # TODO: delete file's data block and parity block
        for path in self.block_path:
            print(f"remove_file: {path}")
            myfile = Path(path) / filename
            filename_combined = filename + ".log"
            myfile_log = Path("/tmp/filename_list") / filename_combined
            try:
                os.remove(myfile)
            except:
                print('檔案不存在')
            try:
                os.remove(myfile_log)
            except:
                print('檔案不存在')

        # del filename_list[filename]
        
        pass

    async def fix_block(self, block_id: int) -> None:
        # TODO: fix the broke block by using rest of block
        
        print("test")
        # 確認哪一塊損壞
        
        # 用其他的block去修復
        
        # 修復後的block放回去
        file_paths = {}
        filename_list = {}
        
        
        for i in range(settings.NUM_DISKS):
            if(i == block_id):
                continue
            all_file_inblock = os.listdir(self.block_path[i])
            for filename in all_file_inblock:
                if filename not in filename_list:
                    filename_list[filename] = 1
                else:
                    filename_list[filename] += 1
            
            
        print(filename_list)
        
        
        restore_files = []
        final_restore_files = []
        
        for key, value in filename_list.items():
            if value == settings.NUM_DISKS-1:
                restore_files.append(key)

        print(restore_files)

        for filename in restore_files:
            is_restore = True;
            check_blocks_bytes = []
            check_block_string = []
            for i in range(settings.NUM_DISKS):
                if(i == block_id):
                    continue
                filepath = f"{self.block_path[i]}"
                filesize = get_file_size(filepath, filename)
                check_blocks_bytes.append(filesize)
                cmd = f"cat {filepath}/{filename}"
                result = subprocess.run(cmd, shell=True, capture_output=True)
                result_bytes = result.stdout
                check_block_string.append(result_bytes)
            for i in range(len(check_blocks_bytes)-1):
                if check_blocks_bytes[i] != check_blocks_bytes[i+1]:
                    print("檔案大小不一致")
                    is_restore = False;
            if is_restore:
                # xor 還原
                final_restore_files.append(filename)
                restore_convert_nums = len(check_block_string[0])
                xor_result = b'\x00' * restore_convert_nums
                for s in check_block_string:
                    xor_result = bytes(a ^ b for a, b in zip(xor_result, s))
                filepath = f"{self.block_path[block_id]}"
                if os.path.isdir(filepath) == False:
                    Path(filepath).mkdir(parents=True, exist_ok=True)
                restore_filepath = f"{filepath}/{filename}"
                file = open(restore_filepath, "wb")
                file.write(xor_result)
                
                # 將檔案寫入 損毀的block
                
        print(final_restore_files)
                
        # for file_name in file_paths[0]:
        #     is_restore = True;
        #     check_blocks_bytes = []
        #     for i in range(settings.NUM_DISKS):
        #         if(i == block_id):
        #             continue
        #         file_path = f"{self.block_path[i]}"
        #         file_size = get_file_size(file_path, file_name)
                
        #         if file_size is not None:
        #             print(f"檔案存在，大小為 {file_size} bytes")
        #             check_blocks_bytes.append(file_size)
        #         else:
        #             print("檔案不存在")
        #             is_restore = False;
        #             continue
        #     # print(check_blocks_bytes.__sizeof__())
        #     for i in range(len(check_blocks_bytes)-1):
        #         if check_blocks_bytes[i] != check_blocks_bytes[i+1]:
        #             print("檔案大小不一致")
        #             is_restore = False;
        #             continue
        #     if is_restore:
        #         restore_files.append(file_name)
            
        print("================================")
        print(restore_files)        
        print(restore_files)
        pass


storage: Storage = Storage(is_test="pytest" in sys.modules)



