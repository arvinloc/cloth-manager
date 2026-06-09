unit FileStorage;


interface

uses DataTypes;


procedure LoadFromFiles;


procedure SaveToFiles;

implementation

uses SysUtils;

// Загрузка

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
  // Чтение типизированного файла товаров так чтобы не было утечки памяти за счет очистки старых эл-тов.
  while TypeHead <> nil do
  begin
    tn := TypeHead;
    TypeHead := TypeHead^.Next;
    Dispose(tn);
  end;

  { Освобождаем старый список товаров }
  while ClothHead <> nil do
  begin
    cn := ClothHead;
    ClothHead := ClothHead^.Next;
    Dispose(cn);
  end;

// Чтение типизированного файла типов
  if FileExists('types.dat') then
  begin
    AssignFile(tf, 'types.dat');
    Reset(tf);
    tlast := nil;
    while not Eof(tf) do
    begin
      Read(tf, tr);        // Чтение одной записи
      New(tn);             // Аллокация памяти для нового узла
      tn^.Data := tr;
      tn^.Next := nil;
      // Добавление в конец вписка
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

  //  Чтение товаров из типизированного файла
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

// Сохранение

procedure SaveToFiles;
var
  tf : TTypeFile;
  cf : TClothFile;
  tn : PTypeNode;
  cn : PClothNode;
begin
  // Перезапись файла типов
  AssignFile(tf, 'types.dat');
  Rewrite(tf);
  tn := TypeHead;
  while tn <> nil do
  begin
    Write(tf, tn^.Data);
    tn := tn^.Next;
  end;
  CloseFile(tf);

   // Перезапись файла товаров
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

