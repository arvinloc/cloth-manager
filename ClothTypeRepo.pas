unit ClothTypeRepo;



interface

uses DataTypes;

// Устанавливает поле Season по числовому коду сезона (1..5).
procedure SetSeason(Code: Integer; var ClothType: TClothType);

// Линейный поиск типа одежды по коду. Возвращает указатель или nil
function FindTypeByCode(Code: Integer): PTypeNode;

// Добавляет новый тип в конец списка.
procedure AddClothType(const Rec: TClothType; var ErrMsg: string);

// Удаляет тип по коду.
// ErrMsg = '' при успехе.
procedure DeleteClothType(Code: Integer; var ErrMsg: string);

// Обновление полей по коду.
procedure UpdateClothType(const Rec: TClothType; var ErrMsg: string);

// Сортировка списка типов одежды по заданному полю:
// Field=1 - по коду, Field=2 - по названию, Field=3 - по сезону.
// Возвращает False, если список пуст.
function SortTypeBy(Field: Integer): Boolean;

implementation



procedure SetSeason(Code: Integer; var ClothType: TClothType);
begin
  // Преобразуем числовой код в строку сезона
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
  // Идём по списку до совпадения кода или до конца
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

 // Проверяем уникальность кода
  if FindTypeByCode(Rec.Code) <> nil then
  begin
    ErrMsg := 'Запись с таким кодом уже существует.';
    Exit;
  end;

  // Создаём узел и добавляем в конец списка
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

 // Ищем предыдущий узел для перешивки указателей
  prev := nil;
  if TypeHead <> n then
  begin
    prev := TypeHead;
    while prev^.Next <> n do prev := prev^.Next;
  end;

  // Отцепляем узел и освобождаем память
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

  //  Перезаписываем поля — код не меняем, только данные
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

  // Пузырёк: повторяем проходы до полного отсутствия перестановок
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
