:Sysprep処理を行うbatファイル
powershell start-process cmd -ArgumentList '/k "cd .\Sysprep\ & .\sysprep.exe /generalize /reboot /oobe"' -verb runas
