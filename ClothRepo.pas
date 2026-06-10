unit ClothRepo;

interface

uses DataTypes;

// установка половозрастного признака в соответствии с кодом который ввел пользователь
procedure SetGender(Code: Integer; var Cloth: TCloth);

// линейный поиск товара по коду
function FindClothByCode(Code: Integer): PClothNode;

// добавление товара
procedure AddCloth(const Rec: TCloth; var ErrMsg: string);

// удаление по коду
procedure DeleteCloth(Code: Integer; var ErrMsg: string);

// обновление полей товара по коду
procedure UpdateCloth(const Rec: TCloth; var ErrMsg: string);

// сортировка списка товаров по заданному полю
// field 1 по коду товара field 2 по коду типа field 3 по бренду модели
// возврат false если список пуст
function SortClothBy(Field: Integer): Boolean;

// подбор товаров по сезону полу и размеру результат отсортирован по цене
procedure SelectGoods(
  const Season, Gender, Size : string;
  var ResultCodes             : array of Integer;
  var ResultCount             : Integer
);

// оформление покупки
procedure BuyGoods(
  Code          : Integer;
  Qty           : Integer;
  var Remaining : Integer;
  var ErrMsg    : string
);

// поиск товаров по заданному полю
// field 1 код товара numval field 2 код типа numval
// field 3 бренд strval field 4 размер strval
// field 5 половозрастной признак strval
procedure SearchCloth(
  Field        : Integer;
  NumVal       : Integer;
  const StrVal : string;
  var ResultCodes : array of Integer;
  var ResultCount : Integer
);

implementation

uses SysUtils, ClothTypeRepo;

procedure SetGender(Code: Integer; var Cloth: TCloth);
begin
  case Code of
    1: Cloth.Gender := 'Мужской';
    2: Cloth.Gender := 'Женский';
    3: Cloth.Gender := 'Детский';
  end;
end;

function FindClothByCode(Code: Integer): PClothNode;
var
  n: PClothNode;
begin
  n := ClothHead;
  // линейный обход до первого совпадения
  while (n <> nil) and (n^.Data.Code <> Code) do
    n := n^.Next;
  FindClothByCode := n;
end;

procedure AddCloth(const Rec: TCloth; var ErrMsg: string);
var
  n    : PClothNode;
  last : PClothNode;
begin
  ErrMsg := '';

  // проверка уникальности кода самого товара
  if FindClothByCode(Rec.Code) <> nil then
  begin
    ErrMsg := 'Запись с таким кодом уже существует.';
    Exit;
  end;

  // проверка существования типа одежды с указанным кодом
  if FindTypeByCode(Rec.TypeCode) = nil then
  begin
    ErrMsg := 'Тип одежды с кодом ' + IntToStr(Rec.TypeCode) + ' не найден.';
    Exit;
  end;

  // создание узла и добавление в конец списка
  New(n);
  n^.Data := Rec;
  n^.Next := nil;

  if ClothHead = nil then
    ClothHead := n
  else
  begin
    last := ClothHead;
    while last^.Next <> nil do last := last^.Next;
    last^.Next := n;
  end;
end;

procedure DeleteCloth(Code: Integer; var ErrMsg: string);
var
  n    : PClothNode;
  prev : PClothNode;
begin
  ErrMsg := '';

  n := FindClothByCode(Code);
  if n = nil then
  begin
    ErrMsg := 'Запись не найдена.';
    Exit;
  end;

  prev := nil;
  if ClothHead <> n then
  begin
    prev := ClothHead;
    while prev^.Next <> n do prev := prev^.Next;
  end;

  if prev = nil then ClothHead := n^.Next
  else prev^.Next := n^.Next;
  Dispose(n);
end;

procedure UpdateCloth(const Rec: TCloth; var ErrMsg: string);
var
  n: PClothNode;
begin
  ErrMsg := '';

  n := FindClothByCode(Rec.Code);
  if n = nil then
  begin
    ErrMsg := 'Запись не найдена.';
    Exit;
  end;

  // перезапись всех полей кроме кода
  n^.Data.TypeCode := Rec.TypeCode;
  n^.Data.Brand    := Rec.Brand;
  n^.Data.Size     := Rec.Size;
  n^.Data.Color    := Rec.Color;
  n^.Data.Price    := Rec.Price;
  n^.Data.Gender   := Rec.Gender;
  n^.Data.Count    := Rec.Count;
end;

function SortClothBy(Field: Integer): Boolean;
var
  i      : PClothNode;
  tmp    : TCloth;
  sorted : Boolean;
  less   : Boolean;
begin
  if ClothHead = nil then
  begin
    SortClothBy := False;
    Exit;
  end;

  // повторение проходов методом пузырька до полного отсутствия перестановок
  repeat
    sorted := True;
    i := ClothHead;
    while i^.Next <> nil do
    begin
      case Field of
        1: less := i^.Data.Code     > i^.Next^.Data.Code;
        2: less := i^.Data.TypeCode > i^.Next^.Data.TypeCode;
        3: less := i^.Data.Brand    > i^.Next^.Data.Brand;
      else
        less := False;
      end;

      if less then
      begin
        // обмен содержимого узлов местами
        tmp           := i^.Data;
        i^.Data       := i^.Next^.Data;
        i^.Next^.Data := tmp;
        sorted        := False;
      end;
      i := i^.Next;
    end;
  until sorted;

  SortClothBy := True;
end;

procedure SelectGoods(
  const Season, Gender, Size : string;
  var ResultCodes             : array of Integer;
  var ResultCount             : Integer
);
var
  n          : PClothNode;
  tn         : PTypeNode;
  typeSeason : string;
  prices     : array[0..199] of Real;
  i, j       : Integer;
  tmpI       : Integer;
  tmpR       : Real;
begin
  ResultCount := 0;
  n := ClothHead;

  // сбор товаров соответствующих всем трем фильтрам
  while (n <> nil) and (ResultCount < 200) do
  begin
    if (n^.Data.Gender = Gender) and
       (n^.Data.Size   = Size)   and
       (n^.Data.Count  > 0)      then
    begin
      // определение сезона через связанный тип одежды
      typeSeason := '';
      tn := FindTypeByCode(n^.Data.TypeCode);
      if tn <> nil then typeSeason := tn^.Data.Season;

      if typeSeason = Season then
      begin
        ResultCodes[ResultCount] := n^.Data.Code;
        prices[ResultCount]      := n^.Data.Price;
        Inc(ResultCount);
      end;
    end;
    n := n^.Next;
  end;

  // сортировка результата по цене пузырьком по массиву
  for i := 0 to ResultCount - 2 do
    for j := 0 to ResultCount - 2 - i do
      if prices[j] > prices[j + 1] then
      begin
        tmpR := prices[j];      prices[j]      := prices[j + 1]; prices[j + 1] := tmpR;
        tmpI := ResultCodes[j]; ResultCodes[j] := ResultCodes[j + 1]; ResultCodes[j + 1] := tmpI;
      end;
end;

procedure BuyGoods(
  Code          : Integer;
  Qty           : Integer;
  var Remaining : Integer;
  var ErrMsg    : string
);
var
  n: PClothNode;
begin
  ErrMsg := '';

  if Qty <= 0 then
  begin
    ErrMsg := 'Количество должно быть больше нуля.';
    Exit;
  end;

  n := FindClothByCode(Code);
  if n = nil then
  begin
    ErrMsg := 'Запись не найдена.';
    Exit;
  end;

  // проверка достаточности остатка
  if n^.Data.Count < Qty then
  begin
    ErrMsg := 'Недостаточно на складе. В наличии: ' + IntToStr(n^.Data.Count) + '.';
    Exit;
  end;

  // уменьшение остатка и возврат нового значения
  n^.Data.Count := n^.Data.Count - Qty;
  Remaining     := n^.Data.Count;
end;

procedure SearchCloth(
  Field        : Integer;
  NumVal       : Integer;
  const StrVal : string;
  var ResultCodes : array of Integer;
  var ResultCount : Integer
);
var
  n     : PClothNode;
  match : Boolean;
begin
  ResultCount := 0;
  n := ClothHead;

  while (n <> nil) and (ResultCount < 200) do
  begin
    // определение совпадения по выбранному полю
    case Field of
      1: match := n^.Data.Code     = NumVal;
      2: match := n^.Data.TypeCode = NumVal;
      3: match := n^.Data.Brand    = StrVal;
      4: match := n^.Data.Size     = StrVal;
      5: match := n^.Data.Gender   = StrVal;
    else
      match := False;
    end;

    if match then
    begin
      ResultCodes[ResultCount] := n^.Data.Code;
      Inc(ResultCount);
    end;
    n := n^.Next;
  end;
end;

end.
