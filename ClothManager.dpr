program ClothManager;


{$APPTYPE CONSOLE}

uses
  SysUtils,
  DataTypes,
  Utils,
  FileStorage,
  ClothTypeRepo,
  ClothRepo,
  UIManager;

begin
  // инициализация указателей на головы связных списков
  TypeHead  := nil;
  ClothHead := nil;
  WriteLn('Добро пожаловать в систему учета товаров ClothManager!');
  // передаача управления модулю интерфейса
  UIManager.RunMainLoop;
end.

