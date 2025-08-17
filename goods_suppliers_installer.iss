; -- goods_installer.iss --
; Inno Setup script for goods.exe

[Setup]
AppName=Goods Suppliers
AppVersion=1.0.6
DefaultDirName={autopf}\GoodsSuppliers
DefaultGroupName=Goods Suppliers
OutputDir=.
OutputBaseFilename=GoodsInstaller
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "C:\goods\goods_suppliers\build\windows\x64\runner\Release\goods.exe"; DestDir: "{app}"; Flags: ignoreversion

; If your app needs DLLs or assets, add them here:
; Source: "C:\goods\goods_suppliers\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Goods Suppliers"; Filename: "{app}\goods.exe"
Name: "{commondesktop}\Goods Suppliers"; Filename: "{app}\goods.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\goods.exe"; Description: "Launch Goods Suppliers"; Flags: nowait postinstall skipifsilent
