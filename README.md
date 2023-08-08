
### Unshackle - Password Bypass Tool
<p align="center">
<a href="#"><img src="https://media.discordapp.net/attachments/1124408428333367367/1135886585594920960/download.png" height="200"></a>
</p>
Unshackle is an open-source tool to bypass Windows and Linux user passwords from a bootable USB based on Linux.

Contributions are welcomed.

To-Do List:

| Feature         | Status |
|-----------------|------------|
| Easy to use | ✅
| Support windows | ✅
| Simple CLI | ✅
| Support linux  | ✅
| Tutorial video  | 🟡
| easy to build  | ❌
| Simple GUI  | ❌

✅ = Done
🟡 = Under development
❌ = Planned  

## Requirements

To use Unshackle, you need:

1. Unshackle ISO
2. Rufus
3. USB pen drive

## Usage

1. Download the Unshackle ISO from the [releases](https://github.com/Fadi002/unshackle/releases/).
2. Download [Rufus](https://rufus.ie/en/) (recommended).
3. Use Rufus to burn the ISO to your USB drive.
4. Boot from the USB and select Unshackle.
5. Choose your OS (Windows or Linux).
6. Let the process finish, then reboot your system.
7. For Windows, press Shift five times on the lock screen.

## Donation 💸
if you liked the project feel free to donate!

BNB : 0xAF0445f3eEDd7f113a47D3a339820F5b4B1F700c

BTC : bc1q5dedemhl64lqrcjpa226l9sf3hx2l9zm6mzszf

ETH : 0xAF0445f3eEDd7f113a47D3a339820F5b4B1F700c

LTC : ltc1qcu8z2wuexn4lq9em4taerkxcxca267lyg8xac8

## Disclaimer

This tool is for educational purposes only. Do not use it for any illegal activities or unauthorized access. Use it at your own risk. We are not liable for any damage caused by its use.

## License

The program, libraries, etc., are licensed under the GNU General Public License.

## Notes
Linux support is in beta, so expect bugs.
You need to disable secure boot in the motherboard settings.
The uninstall command for Windows has a bug (99% of the time) that causes it to fail, but you can manually uninstall it.
<details>
  <summary>uninstall commands</summary>
```batch
takeown /F "%SystemRoot%\System32\sethc.exe" /A
takeown /F "%SystemRoot%\System32\sethc.exe.old" /A
del /f "%SystemRoot%\System32\sethc.exe"
move /y "%SystemRoot%\System32\sethc.exe.old" "%SystemRoot%\System32\sethc.exe"
```
</details>

