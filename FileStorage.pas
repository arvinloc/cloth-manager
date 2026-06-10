unit FileStorage;

interface

uses DataTypes;

// загрузка данных из файлов
procedure LoadFromFiles;

// сохранение данных в файлы
procedure SaveToFiles;

implementation

uses SysUtils;

procedure LoadFromFiles;
var
  tf    : TTypeFile;
  cf    : TClothFile;
  tr    : TClothType;
  cr    : TCloth;
  tn    : PTypeNode;
  cn    : PClothNode;
  tlast : PTypeNode;
  clast : PClothNode;
begin
  // очистка старых элементов списка для предотвращения утечки памяти
  while TypeHead <> nil do
  begin
    tn := TypeHead;
    TypeHead := TypeHead^.Next;
    Dispose(tn);
  end;

  // освобождение старого списка товаров
  while ClothHead <> nil do
  begin
    cn := ClothHead;
    ClothHead := ClothHead^.Next;
    Dispose(cn);
  end;

  // чтение типизированного файла типов
  if FileExists('types.dat') then
  begin
    AssignFile(tf, 'types.dat');
    Reset(tf);
    tlast := nil;
    while not Eof(tf) do
    begin
      Read(tf, tr);
      New(tn);
      tn^.Data := tr;
      tn^.Next := nil;
      // добавление в конец списка
      if TypeHead = nil then TypeHead := tn
      else
        tlast^.Next := tn;
      tlast := tn;
    end;
    CloseFile(tf);
    Writeln('Типы одежды загружены.');
  end
  else
    Writeln('Файл types.dat не найден, список пуст.');

  // чтение товаров из типизированного файла
  if FileExists('cloth.dat') then
  begin
    AssignFile(cf, 'cloth.dat');
    Reset(cf);
    clast := nil;
    while not Eof(cf) do
    begin
      Read(cf, cr);
      New(cn);
      cn^.Data := cr;
      cn^.Next := nil;
      if ClothHead = nil then ClothHead := cn
      else clast^.Next := cn;
      clast := cn;
    end;
    CloseFile(cf);
    Writeln('Товары загружены.');
  end
  else
    Writeln('Файл cloth.dat не найден, список пуст.');
end;

procedure SaveToFiles;
var
  tf : TTypeFile;
  cf : TClothFile;
  tn : PTypeNode;
  cn : PClothNode;
begin
  // перезапись файла типов
  AssignFile(tf, 'types.dat');
  Rewrite(tf);
  tn := TypeHead;
  while tn <> nil do
  begin
    Write(tf, tn^.Data);
    tn := tn^.Next;
  end;
  CloseFile(tf);

  // перезапись файла товаров
  AssignFile(cf, 'cloth.dat');
  Rewrite(cf);
  cn := ClothHead;
  while cn <> nil do
  begin
    Write(cf, cn^.Data);
    cn := cn^.Next;
  end;
  CloseFile(cf);

  Writeln('Данные сохранены в файлы.');
end;

end.
