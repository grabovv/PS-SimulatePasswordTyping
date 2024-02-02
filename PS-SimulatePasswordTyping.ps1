Add-Type -TypeDefinition '
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace KeyP {
    public static class Program {
        private const int WH_KEYBOARD_LL = 13;
        private const int WM_KEYDOWN = 0x0100;

        private static HookProc hookProc = HookCallback;
        private static IntPtr hookId = IntPtr.Zero;
        private static int keyCode = 0;

        [DllImport("user32.dll")]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll")]
        private static extern bool UnhookWindowsHookEx(IntPtr hhk);

        [DllImport("user32.dll")]
        private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

        [DllImport("kernel32.dll")]
        private static extern IntPtr GetModuleHandle(string lpModuleName);

        public static int WaitForKey() {
            hookId = SetHook(hookProc);
            Application.Run();
            UnhookWindowsHookEx(hookId);
            return keyCode;
        }

        private static IntPtr SetHook(HookProc hookProc) {
            IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
            return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
        }

        private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

        private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
            if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
                keyCode = Marshal.ReadInt32(lParam);
                Application.Exit();
            }
            return CallNextHookEx(hookId, nCode, wParam, lParam);
        }
    }
}
' -ReferencedAssemblies System.Windows.Forms

cls
$delay = Read-Host -Prompt "How long to wait before pasting the text (in seconds)"

cls

Write-Host "The application is active. Press F8 in any window to paste clipboard content" -ForegroundColor Green
Write-Host "Content will be pasted with a delay of $delay seconds" -ForegroundColor Yellow

while ($true) {
    $key = [System.Windows.Forms.Keys][KeyP.Program]::WaitForKey()
    if ($key -eq "F8") {
        $wshell = New-Object -ComObject wscript.shell
        $clipboardContent = Get-Clipboard
        $charArray = $clipboardContent.ToCharArray()

        cls
        $timeStamp = (Get-Date).ToString('T')
        Write-Host "Press [CTRL + Z] to exit the application" -ForegroundColor Red
        Write-Host "Press [F8] to paste" -ForegroundColor Green
        Write-Host "Delay is set to $delay seconds" -ForegroundColor Yellow
        Write-Host "Detected " $charArray.Count " characters." -ForegroundColor Green

        if ([string]::IsNullOrEmpty($charArray)) {
            Write-Host "`n[$timeStamp] Nothing pasted, clipboard is empty!" -ForegroundColor Red
        } else {
            Sleep $delay
            Write-Host ""

            foreach ($character in $charArray) {
                try {
                    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
                    [System.Windows.Forms.SendKeys]::SendWait("{$character}")
                } catch {
                    Write-Host "Error while processing character '$character'"
                }
            }
            Write-Host "`n[$timeStamp] Done" -ForegroundColor Magenta
        }
    }
}
