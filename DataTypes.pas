unit DataTypes;

interface

type
  // запись типа одежды
  TClothType = record
    Code   : Integer;      { уникальный числовой код типа }
    Name   : string[50];   { наименование типа одежды }
    Season : string[20];   { сезон зима весна лето осень }
  end;

  // запись товара
  TCloth = record
    Code     : Integer;    // уникальный числовой код товара
    TypeCode : Integer;    // код типа одежды внешний ключ на TClothType
    Brand    : string[50]; // бренд и модель
    Size     : string[10]; // размер m/l/42/44-66/ итд
    Color    : string[20]; // цвет
    Price    : Real;       // цена в рублях
    Gender   : string[10]; // пол мужской женский детский
    Count    : Integer;    // количество единиц на складе
  end;

// типизированные файлы

type
  TTypeFile  = file of TClothType; // типизированный файл типов одежды
  TClothFile = file of TCloth;     // типизированный файл товаров

// узлы односвязных списков

type
  PTypeNode = ^TTypeNode;
  TTypeNode = record
    Data : TClothType; // данные узла тип одежды
    Next : PTypeNode;  // указатель на следующий узел
  end;

  PClothNode = ^TClothNode;
  TClothNode = record
    Data : TCloth;     // данные узла товар
    Next : PClothNode; // указатель на следующий узел
  end;

// головы списков
var
  TypeHead  : PTypeNode;
  ClothHead : PClothNode;

implementation

end.
