unit DataTypes;



interface



type
 // Запись типа одежды
  TClothType = record
    Code   : Integer;      { Уникальный числовой код типа }
    Name   : string[50];   { Название типа одежды }
    Season : string[20];   { Сезон: Зима / Весна / Лето / Осень }
  end;

  // Запись товара
  TCloth = record
    Code     : Integer;    { Уникальный числовой код товара }
    TypeCode : Integer;    { Код типа одежды (внешний ключ -> TClothType) }
    Brand    : string[50]; { Бренд и модель }
    Size     : string[10]; { Размер (например: M, L, 42, 44-66 и т.д.) }
    Color    : string[20]; { Цвет }
    Price    : Real;       { Цена в рублях }
    Gender   : string[10]; { Пол: Мужской / Женский / Детский }
    Count    : Integer;    { Количество единиц на складе }
  end;

// Типизированные файлы

type
  TTypeFile  = file of TClothType; { Бинарный файл типов одежды }
  TClothFile = file of TCloth;     { Бинарный файл товаров }

// Узлы односвязных списков

type
  PTypeNode = ^TTypeNode;
  TTypeNode = record
    Data : TClothType; { Данные узла — тип одежды }
    Next : PTypeNode;  { Указатель на следующий узел }
  end;

  PClothNode = ^TClothNode;
  TClothNode = record
    Data : TCloth;     { Данные узла — товар }
    Next : PClothNode; { Указатель на следующий узел }
  end;

// Головы списков

var

  TypeHead  : PTypeNode;


  ClothHead : PClothNode;

implementation



end.

