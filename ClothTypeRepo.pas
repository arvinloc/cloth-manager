unit ClothTypeRepo;

interface

uses DataTypes;

// устанавливает поле season по числовому коду сезона от 1 до 5
procedure SetSeason(Code: Integer; var ClothType: TClothType);

// выполняет линейный поиск типа одежды по коду
// возвращает указатель или nil
function FindTypeByCode(Code: Integer): PTypeNode;

// добавляет новый тип в конец списка
procedure AddClothType(const Rec: TClothType; var ErrMsg: string);

// удаляет тип по коду
// очищает ErrMsg при успешном выполнении процедуры
procedure DeleteClothType(Code: Integer; var ErrMsg: string);

// обновляет поля по коду
procedure UpdateClothType(const Rec: TClothType; var ErrMsg: string);

// сортирует список типов одежды по заданному полю
// сортирует по коду если field 1 по названию если field 2 по сезону если field 3
// возвращает false если список пуст
function SortTypeBy(Field: Integer): Boolean;

implementation

procedure SetSeason(Code: Integer; var ClothType: TClothType);
begin
  // преобразует числовой код в строку сезона
  case Code of
    1: ClothType.Season := 'Зима';
    2: ClothType.Season := 'Весна';
    3: ClothType.Season := 'Лето';
    4: ClothType.Season := 'Осень';
    5: ClothType.Season := 'Всесезонный';
  end;
end;

function FindTypeByCode(Code: Integer): PTypeNode;
var
  n: PTypeNode;
begin
  n := TypeHead;
  // проходит по списку до совпадения кода или до конца
  while (n <> nil) and (n^.Data.Code <> Code) do
    n := n^.Next;
  FindTypeByCode := n;
end;

procedure AddClothType(const Rec: TClothType; var ErrMsg: string);
var
  n    : PTypeNode;
  last : PTypeNode;
begin
  ErrMsg := '';

  // проверяет уникальность кода
  if FindTypeByCode(Rec.Code) <> nil then
  begin
    ErrMsg := 'Запись с таким кодом уже существует.';
    Exit;
  end;

  // создает узел и добавляет в конец списка
  New(n);
  n^.Data := Rec;
  n^.Next := nil;

  if TypeHead = nil then
    TypeHead := n
  else
  begin
    last := TypeHead;
    while last^.Next <> nil do last := last^.Next;
    last^.Next := n;
  end;
end;

procedure DeleteClothType(Code: Integer; var ErrMsg: string);
var
  n    : PTypeNode;
  prev : PTypeNode;
begin
  ErrMsg := '';

  n := FindTypeByCode(Code);
  if n = nil then
  begin
    ErrMsg := 'Запись не найдена.';
    Exit;
  end;

  // ищет предыдущий узел для замены указателей
  prev := nil;
  if TypeHead <> n then
  begin
    prev := TypeHead;
    while prev^.Next <> n do prev := prev^.Next;
  end;

  // отцепляет узел и освобождает память
  if prev = nil then TypeHead := n^.Next
  else prev^.Next := n^.Next;
  Dispose(n);
end;

procedure UpdateClothType(const Rec: TClothType; var ErrMsg: string);
var
  n: PTypeNode;
begin
  ErrMsg := '';

  n := FindTypeByCode(Rec.Code);
  if n = nil then
  begin
    ErrMsg := 'Запись не найдена.';
    Exit;
  end;

  // перезаписывает поля только данные без кода
  n^.Data.Name   := Rec.Name;
  n^.Data.Season := Rec.Season;
end;

function SortTypeBy(Field: Integer): Boolean;
var
  i      : PTypeNode;
  tmp    : TClothType;
  sorted : Boolean;
  less   : Boolean;
begin
  if TypeHead = nil then
  begin
    SortTypeBy := False;
    Exit;
  end;

  // повторяет проходы методом пузырька до полного отсутствия перестановок
  repeat
    sorted := True;
    i := TypeHead;
    while i^.Next <> nil do
    begin
      case Field of
        1: less := i^.Data.Code  > i^.Next^.Data.Code;
        2: less := i^.Data.Name  > i^.Next^.Data.Name;
        3: less := i^.Data.Season > i^.Next^.Data.Season;
      else
        less := False;
      end;

      if less then
      begin
        tmp           := i^.Data;
        i^.Data       := i^.Next^.Data;
        i^.Next^.Data := tmp;
        sorted        := False;
      end;
      i := i^.Next;
    end;
  until sorted;

  SortTypeBy := True;
end;

end.
