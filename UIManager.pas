unit UIManager;

interface

// запуск цикла программы
procedure RunMainLoop;

implementation

uses
  SysUtils,
  DataTypes,
  Utils,
  FileStorage,
  ClothTypeRepo,
  ClothRepo;

// вывод одной строки таблицы типов одежды
procedure PrintTypeRow(const Rec: TClothType);
begin

  Writeln(
    Rec.Code:4, '  ',
    Rec.Name:33, '  ',
    Rec.Season:12
  );
end;

// вывод шапки таблицы типов одежды
procedure PrintTypeHeader;
begin

  Writeln(
    'Код':4, '  ',
    'Название':33, '  ',
    'Сезон':12
  );

  Writeln(
    '----':4, '  ',
    '---------------------------------':33, '  ',
    '------------':12
  );
end;

// вывод одной строки таблицы товаров
procedure PrintClothRow(const Rec: TCloth);
begin
  Writeln(
    Rec.Code:4, '  ',
    Rec.TypeCode:9, '  ',
    Rec.Brand:30, '  ',
    Rec.Size:6, '  ',
    Rec.Color:12, '  ',
    Rec.Price:8:2, '  ',
    Rec.Gender:10, '  ',
    Rec.Count:6
  );
end;

// вывод шапки таблицы товаров
procedure PrintClothHeader;
begin
  Writeln(
    'Код':4, '  ',
    'Код типа':9, '  ',
    'Бренд/Модель':30, '  ',
    'Размер':6, '  ',
    'Цвет':12, '  ',
    'Цена':8, '  ',
    'Пол':10, '  ',
    'Кол-во':6
  );
  Writeln(
    '----':4, '  ',
    '---------':9, '  ',
    '------------------------------':30, '  ',
    '------':6, '  ',
    '------------':12, '  ',
    '--------':8, '  ',
    '----------':10, '  ',
    '------':6
  );
end;

procedure ShowAllTypes;
var
  n: PTypeNode;
begin
  if TypeHead = nil then
  begin
    Writeln('Список типов одежды пуст.');
    Exit;
  end;
  PrintTypeHeader;
  n := TypeHead;
  while n <> nil do
  begin
    PrintTypeRow(n^.Data);
    n := n^.Next;
  end;
end;

procedure ShowAllCloth;
var
  n: PClothNode;
begin
  if ClothHead = nil then
  begin
    Writeln('Список товаров пуст.');
    Exit;
  end;
  PrintClothHeader;
  n := ClothHead;
  while n <> nil do
  begin
    PrintClothRow(n^.Data);
    n := n^.Next;
  end;
end;

procedure UIAddClothType;
var
  r      : TClothType;
  num    : Integer;
  s      : string;
  ok     : Boolean;
  ErrMsg : string;
begin
  ReadInt('Код типа: ', r.Code, ok);
  if not ok then Exit;

  ReadStr('Название: ', s, ok);
  if not ok then Exit;
  r.Name := s;

  Writeln('Сезон: 1 - Зима, 2 - Весна, 3 - Лето, 4 - Осень, 5 - Всесезонный');
  ReadInt('Введите номер сезона: ', num, ok);
  if not ok then Exit;
  if (num < 1) or (num > 5) then
  begin
    Writeln('Ошибка: введите число от 1 до 5.');
    Exit;
  end;
  SetSeason(num, r);

  AddClothType(r, ErrMsg);

  if ErrMsg = '' then Writeln('Тип одежды добавлен.')
  else Writeln('Ошибка: ', ErrMsg);
end;

procedure UIDeleteClothType;
var
  code   : Integer;
  ok     : Boolean;
  ErrMsg : string;
begin
  ReadInt('Код типа для удаления: ', code, ok);
  if not ok then Exit;

  DeleteClothType(code, ErrMsg);

  if ErrMsg = '' then Writeln('Тип одежды удалён.')
  else Writeln('Ошибка: ', ErrMsg);
end;

procedure UIEditClothType;
var
  code   : Integer;
  num    : Integer;
  field  : Integer;
  n      : PTypeNode;
  r      : TClothType;
  s      : string;
  ok     : Boolean;
  ErrMsg : string;
begin
  ReadInt('Код типа для редактирования: ', code, ok);
  if not ok then Exit;

  n := FindTypeByCode(code);
  if n = nil then
  begin
    Writeln('Ошибка: запись не найдена.');
    Exit;
  end;

  r := n^.Data;

  Writeln('Выберите поле для изменения:');
  Writeln('1. Название типа товара (', n^.Data.Name, ')');
  Writeln('2. Сезон (', n^.Data.Season, ')');
  Writeln('3. Сохранить и вернуться в главное меню');
  ReadInt('Выбор: ', field, ok);
  if not ok or (field = 3) then Exit;

  case field of
    1:
    begin
      ReadStr('Новое название: ', s, ok);
      if not ok then Exit;
      r.Name := s;
    end;
    2:
    begin
      Writeln('Сезон: 1 - Зима, 2 - Весна, 3 - Лето, 4 - Осень, 5 - Всесезонный');
      ReadInt('Введите номер сезона: ', num, ok);
      if not ok then Exit;
      if (num < 1) or (num > 5) then
      begin
        Writeln('Ошибка: введите число от 1 до 5.');
        Exit;
      end;
      SetSeason(num, r);
    end;
  else
    Writeln('Неверный выбор поля.');
    Exit;
  end;

  UpdateClothType(r, ErrMsg);

  if ErrMsg = '' then Writeln('Тип одежды обновлён.')
  else Writeln('Ошибка: ', ErrMsg);
end;

procedure UIAddCloth;
var
  r      : TCloth;
  num    : Integer;
  s      : string;
  ok     : Boolean;
  ErrMsg : string;
begin
  ReadInt('Код товара: ', r.Code, ok);
  if not ok then Exit;

  ReadInt('Код типа одежды: ', r.TypeCode, ok);
  if not ok then Exit;

  ReadStr('Бренд и модель: ', s, ok);
  if not ok then Exit;
  r.Brand := s;

  ReadStr('Размер: ', s, ok);
  if not ok then Exit;
  r.Size := s;

  ReadStr('Цвет: ', s, ok);
  if not ok then Exit;
  r.Color := s;

  ReadReal('Цена: ', r.Price, ok);
  if not ok then Exit;

  ReadInt('Количество: ', r.Count, ok);
  if not ok then Exit;

  Writeln('Пол: 1 - Мужской, 2 - Женский, 3 - Детский');
  ReadInt('Введите номер: ', num, ok);
  if not ok then Exit;
  if (num < 1) or (num > 3) then
  begin
    Writeln('Ошибка: введите число от 1 до 3.');
    Exit;
  end;
  SetGender(num, r);

  AddCloth(r, ErrMsg);

  if ErrMsg = '' then Writeln('Товар добавлен.')
  else Writeln('Ошибка: ', ErrMsg);
end;

procedure UIDeleteCloth;
var
  code   : Integer;
  ok     : Boolean;
  ErrMsg : string;
begin
  ReadInt('Код товара для удаления: ', code, ok);
  if not ok then Exit;

  DeleteCloth(code, ErrMsg);

  if ErrMsg = '' then Writeln('Товар удалён.')
  else Writeln('Ошибка: ', ErrMsg);
end;

procedure UIEditCloth;
var
  code   : Integer;
  field  : Integer;
  num    : Integer;
  n      : PClothNode;
  r      : TCloth;
  s      : string;
  ok     : Boolean;
  ErrMsg : string;
begin
  ReadInt('Код товара для редактирования: ', code, ok);
  if not ok then Exit;

  n := FindClothByCode(code);
  if n = nil then
  begin
    Writeln('Ошибка: запись не найдена.');
    Exit;
  end;

  r := n^.Data;

  Writeln('Выберите поле для изменения:');
  Writeln('1. Код типа товара (', n^.Data.TypeCode, ')');
  Writeln('2. Бренд/Модель (', n^.Data.Brand, ')');
  Writeln('3. Размер (', n^.Data.Size, ')');
  Writeln('4. Цвет (', n^.Data.Color, ')');
  Writeln('5. Стоимость (', n^.Data.Price:0:2, ')');
  Writeln('6. Количество в наличии (', n^.Data.Count, ')');
  Writeln('7. Половозрастной признак (', n^.Data.Gender, ')');
  Writeln('8. Сохранить и вернуться в главное меню');
  ReadInt('Выбор: ', field, ok);
  if not ok or (field = 8) then Exit;

  case field of
    1:
    begin
      ReadInt('Новый код типа товара: ', r.TypeCode, ok);
      if not ok then Exit;
    end;
    2:
    begin
      ReadStr('Новый бренд/модель: ', s, ok);
      if not ok then Exit;
      r.Brand := s;
    end;
    3:
    begin
      ReadStr('Новый размер: ', s, ok);
      if not ok then Exit;
      r.Size := s;
    end;
    4:
    begin
      ReadStr('Новый цвет: ', s, ok);
      if not ok then Exit;
      r.Color := s;
    end;
    5:
    begin
      ReadReal('Новая стоимость: ', r.Price, ok);
      if not ok then Exit;
    end;
    6:
    begin
      ReadInt('Новое количество: ', r.Count, ok);
      if not ok then Exit;
    end;
    7:
    begin
      Writeln('Пол: 1 - Мужской, 2 - Женский, 3 - Детский');
      ReadInt('Введите номер: ', num, ok);
      if not ok then Exit;
      if (num < 1) or (num > 3) then
      begin
        Writeln('Ошибка: введите число от 1 до 3.');
        Exit;
      end;
      SetGender(num, r);
    end;
  else
    Writeln('Неверный выбор поля.');
    Exit;
  end;

  UpdateCloth(r, ErrMsg);

  if ErrMsg = '' then Writeln('Товар обновлён.')
  else Writeln('Ошибка: ', ErrMsg);
end;

procedure UISearchCloth;
var
  sub         : Integer;
  ok          : Boolean;
  num         : Integer;
  s           : string;
  codes       : array[0..199] of Integer;
  cnt, i      : Integer;
  n           : PClothNode;
begin
  Writeln('Искать по:');
  Writeln('1. Коду товара');
  Writeln('2. Коду типа товара');
  Writeln('3. Бренду/модели');
  Writeln('4. Размеру');
  Writeln('5. Половозрастному признаку');
  Writeln('6. Вернуться в главное меню');
  ReadInt('Выбор: ', sub, ok);
  if not ok or (sub = 6) then Exit;
  if (sub < 1) or (sub > 5) then
  begin
    Writeln('Неверный выбор.');
    Exit;
  end;

  num := 0; s := '';
  case sub of
    1: begin ReadInt('Код товара: ', num, ok);      if not ok then Exit; end;
    2: begin ReadInt('Код типа товара: ', num, ok); if not ok then Exit; end;
    3: begin ReadStr('Бренд/модель: ', s, ok);      if not ok then Exit; end;
    4: begin ReadStr('Размер: ', s, ok);             if not ok then Exit; end;
    5: begin
         Writeln('Пол: 1 - Мужской, 2 - Женский, 3 - Детский');
         ReadInt('Введите номер: ', num, ok);
         if not ok then Exit;
         if (num < 1) or (num > 3) then
         begin
           Writeln('Ошибка: введите число от 1 до 3.');
           Exit;
         end;
         case num of
           1: s := 'Мужской'; 2: s := 'Женский'; 3: s := 'Детский';
         end;
         sub := 5;
       end;
  end;

  SearchCloth(sub, num, s, codes, cnt);

  if cnt = 0 then
  begin
    Writeln('Ничего не найдено.');
    Exit;
  end;

  PrintClothHeader;
  for i := 0 to cnt - 1 do
  begin
    n := FindClothByCode(codes[i]);
    if n <> nil then PrintClothRow(n^.Data);
  end;
end;

procedure UISearchType;
var
  sub    : Integer;
  ok     : Boolean;
  num    : Integer;
  s      : string;
  tn     : PTypeNode;
  found  : Boolean;
begin
  Writeln('Искать по:');
  Writeln('1. Коду типа товара');
  Writeln('2. Сезону');
  Writeln('3. Вернуться в главное меню');
  ReadInt('Выбор: ', sub, ok);
  if not ok or (sub = 3) then Exit;
  if (sub < 1) or (sub > 2) then
  begin
    Writeln('Неверный выбор.');
    Exit;
  end;

  num := 0; s := '';
  case sub of
    1: begin ReadInt('Код типа товара: ', num, ok); if not ok then Exit; end;
    2: begin
         Writeln('Сезон: 1 - Зима, 2 - Весна, 3 - Лето, 4 - Осень, 5 - Всесезонный');
         ReadInt('Введите номер сезона: ', num, ok);
         if not ok then Exit;
         if (num < 1) or (num > 5) then
         begin
           Writeln('Ошибка: введите число от 1 до 5.');
           Exit;
         end;
         case num of
           1: s := 'Зима'; 2: s := 'Весна'; 3: s := 'Лето';
           4: s := 'Осень'; 5: s := 'Всесезонный';
         end;
       end;
  end;

  found := False;
  PrintTypeHeader;
  tn := TypeHead;
  while tn <> nil do
  begin
    if ((sub = 1) and (tn^.Data.Code = num)) or
       ((sub = 2) and (tn^.Data.Season = s)) then
    begin
      PrintTypeRow(tn^.Data);
      found := True;
    end;
    tn := tn^.Next;
  end;
  if not found then Writeln('Ничего не найдено.');
end;

procedure UISearch;
var
  list : Integer;
  ok   : Boolean;
begin
  Writeln('Выберите список:');
  Writeln('1. Список товаров');
  Writeln('2. Список типов одежды');
  Writeln('3. Вернуться в главное меню');
  ReadInt('Выбор: ', list, ok);
  if not ok or (list = 3) then Exit;
  case list of
    1: UISearchCloth;
    2: UISearchType;
  else
    Writeln('Неверный выбор.');
  end;
end;

// ---- сортировка ----

procedure UISortCloth;
var
  sub : Integer;
  ok  : Boolean;
begin
  Writeln('Сортировать список товаров по:');
  Writeln('1. Коду товара');
  Writeln('2. Коду типа одежды');
  Writeln('3. Бренду/модели');
  Writeln('4. Вернуться в главное меню');
  ReadInt('Выбор: ', sub, ok);
  if not ok or (sub = 4) then Exit;
  case sub of
    1:
      if SortClothBy(1) then Writeln('Список товаров отсортирован по коду товара.')
      else Writeln('Список товаров пуст.');
    2:
      if SortClothBy(2) then Writeln('Список товаров отсортирован по коду типа.')
      else Writeln('Список товаров пуст.');
    3:
      if SortClothBy(3) then Writeln('Список товаров отсортирован по бренду/модели.')
      else Writeln('Список товаров пуст.');
  else
    Writeln('Неверный выбор.');
  end;
end;

procedure UISortType;
var
  sub : Integer;
  ok  : Boolean;
begin
  Writeln('Сортировать список типов одежды по:');
  Writeln('1. Коду типа');
  Writeln('2. Наименованию типа товара');
  Writeln('3. Сезону');
  Writeln('4. Вернуться в главное меню');
  ReadInt('Выбор: ', sub, ok);
  if not ok or (sub = 4) then Exit;
  case sub of
    1:
      if SortTypeBy(1) then Writeln('Список типов отсортирован по коду.')
      else Writeln('Список типов пуст.');
    2:
      if SortTypeBy(2) then Writeln('Список типов отсортирован по наименованию.')
      else Writeln('Список типов пуст.');
    3:
      if SortTypeBy(3) then Writeln('Список типов отсортирован по сезону.')
      else Writeln('Список типов пуст.');
  else
    Writeln('Неверный выбор.');
  end;
end;

procedure UISort;
var
  list : Integer;
  ok   : Boolean;
begin
  Writeln('Выберите список:');
  Writeln('1. Список товаров');
  Writeln('2. Список типов одежды');
  Writeln('3. Вернуться в главное меню');
  ReadInt('Выбор: ', list, ok);
  if not ok or (list = 3) then Exit;
  case list of
    1: UISortCloth;
    2: UISortType;
  else
    Writeln('Неверный выбор.');
  end;
end;

// ---- меню подбора и покупки ----

procedure UISelectGoods;
var
  seasonNum  : Integer;
  genderNum  : Integer;
  seasonTmp  : TClothType;
  genderTmp  : TCloth;
  season     : string;
  gender     : string;
  size       : string;
  codes      : array[0..199] of Integer;
  cnt, i     : Integer;
  ok         : Boolean;
  n          : PClothNode;
  tf         : Text;
  fname      : string;
begin
  Writeln('Сезон: 1 - Зима, 2 - Весна, 3 - Лето, 4 - Осень, 5 - Всесезонный');
  ReadInt('Введите номер сезона: ', seasonNum, ok);
  if not ok then Exit;
  if (seasonNum < 1) or (seasonNum > 5) then
  begin
    Writeln('Ошибка: введите число от 1 до 5.');
    Exit;
  end;
  SetSeason(seasonNum, seasonTmp);
  season := seasonTmp.Season;

  Writeln('Пол: 1 - Мужской, 2 - Женский, 3 - Детский');
  ReadInt('Введите номер: ', genderNum, ok);
  if not ok then Exit;
  if (genderNum < 1) or (genderNum > 3) then
  begin
    Writeln('Ошибка: введите число от 1 до 3.');
    Exit;
  end;
  SetGender(genderNum, genderTmp);
  gender := genderTmp.Gender;

  ReadStr('Размер: ', size, ok);
  if not ok then Exit;

  SelectGoods(season, gender, size, codes, cnt);

  if cnt = 0 then
  begin
    Writeln('Подходящих товаров не найдено.');
    Exit;
  end;

  Writeln('Подобранные товары (по цене):');
  PrintClothHeader;

  fname := 'selection' + FormatDateTime('ddmmyyyy_hhnnss', Now) + '.txt';
  AssignFile(tf, fname);
  Rewrite(tf);
  Writeln(tf, 'Подбор: сезон=', season, ' пол=', gender, ' размер=', size);

  for i := 0 to cnt - 1 do
  begin
    n := FindClothByCode(codes[i]);
    if n <> nil then
    begin
      PrintClothRow(n^.Data);
      Writeln(tf,
        n^.Data.Code:4, '  ', n^.Data.Brand:30, '  ',
        n^.Data.Size:6, '  ', n^.Data.Color:12, '  ', n^.Data.Price:8:2);
    end;
  end;

  CloseFile(tf);
  Writeln('Результат сохранён в ', fname);
end;

procedure UIBuyGoods;
var
  code      : Integer;
  qty       : Integer;
  remaining : Integer;
  confirm   : string;
  ok        : Boolean;
  ErrMsg    : string;
  n         : PClothNode;
  tf        : Text;
  fname     : string;
begin
  ReadInt('Введите код товара: ', code, ok);
  if not ok then Exit;

  ReadInt('Введите желаемое количество для покупки: ', qty, ok);
  if not ok then Exit;

  // проверка наличия товара перед подтверждением
  n := FindClothByCode(code);
  if n = nil then
  begin
    Writeln('Ошибка: товар с кодом ', code, ' не найден.');
    Exit;
  end;

  Writeln('Товар: ', n^.Data.Brand, ', размер: ', n^.Data.Size,
          ', цена: ', n^.Data.Price:0:2, ' руб., в наличии: ', n^.Data.Count, ' шт.');
  Write('Подтвердить оформление покупки ', qty, ' шт.? (д/н): ');
  Readln(confirm);
  if (confirm <> 'д') and (confirm <> 'Д') and
     (confirm <> 'y') and (confirm <> 'Y') then
  begin
    Writeln('Покупка отменена.');
    Exit;
  end;

  BuyGoods(code, qty, remaining, ErrMsg);

  if ErrMsg <> '' then
  begin
    Writeln('Ошибка: ', ErrMsg);
    Exit;
  end;

  // запись чека в файл
  fname := 'receipt' + FormatDateTime('ddmmyyyy_hhnnss', Now) + '.txt';
  AssignFile(tf, fname);
  Rewrite(tf);
  Writeln(tf, '================================');
  Writeln(tf, '          ЧЕК ПОКУПКИ           ');
  Writeln(tf, '================================');
  Writeln(tf, 'Дата: ', DateTimeToStr(Now));
  Writeln(tf, '--------------------------------');
  Writeln(tf, 'Код товара : ', n^.Data.Code);
  Writeln(tf, 'Наименование: ', n^.Data.Brand);
  Writeln(tf, 'Размер     : ', n^.Data.Size);
  Writeln(tf, 'Цвет       : ', n^.Data.Color);
  Writeln(tf, 'Пол        : ', n^.Data.Gender);
  Writeln(tf, '--------------------------------');
  Writeln(tf, 'Цена за шт.: ', n^.Data.Price:8:2, ' руб.');
  Writeln(tf, 'Количество : ', qty, ' шт.');
  Writeln(tf, 'ИТОГО      : ', n^.Data.Price * qty:8:2, ' руб.');
  Writeln(tf, '--------------------------------');
  CloseFile(tf);

  Writeln('Покупка оформлена. Остаток на складе: ', remaining, ' шт.');
  Writeln('Чек сохранён в ', fname);
end;

// меню программы
procedure ShowMenu;
begin
  Writeln;
  Writeln('=== ClothManager ===');
  Writeln(' 1.  Считать данные из файла');
  Writeln(' 2.  Просмотр всего списка');
  Writeln(' 3.  Отсортировать список');
  Writeln(' 4.  Поиск записи в списке');
  Writeln(' 5.  Добавить запись в список');
  Writeln(' 6.  Удалить запись из списка');
  Writeln(' 7.  Редактировать запись');
  Writeln(' 8.  Подбор товара и оформление покупки');
  Writeln(' 9.  Выйти без сохранения');
  Writeln('10.  Выйти с сохранением');
  Write('Выбор: ');
end;

procedure ShowListMenu;
begin
  Writeln;
  Writeln('1. Список товаров');
  Writeln('2. Список типов одежды');
  Writeln('3. Вернуться в главное меню');
  Write('Выбор: ');
end;

procedure ShowSpecialMenu;
begin
  Writeln;
  Writeln('1. Подобрать товар');
  Writeln('2. Купить товар');
  Writeln('3. Вернуться в главное меню');
  Write('Выбор: ');
end;

// основной цикл интерфейса

procedure RunMainLoop;
var
  Running : Boolean;
  choice  : Integer;
  sub     : Integer;
  confirm : string;
begin
  Running := True;
  Writeln('Для начала загрузите данные (пункт 1).');

  while Running do
  begin
    ShowMenu;

    try
      Readln(choice);
    except
      choice := 0;
    end;

    case choice of

      1: LoadFromFiles;

      2:
      begin
        ShowListMenu;
        Readln(sub);
        case sub of
          1: ShowAllCloth;
          2: ShowAllTypes;
          3: ;
        else
          Writeln('Неверный выбор.');
        end;
      end;

      3: UISort;

      4: UISearch;

      5:
      begin
        ShowListMenu;
        Readln(sub);
        case sub of
          1: UIAddCloth;
          2: UIAddClothType;
          3: ;
        else
          Writeln('Неверный выбор.');
        end;
      end;

      6:
      begin
        ShowListMenu;
        Readln(sub);
        case sub of
          1: UIDeleteCloth;
          2: UIDeleteClothType;
          3: ;
        else
          Writeln('Неверный выбор.');
        end;
      end;

      7:
      begin
        ShowListMenu;
        Readln(sub);
        case sub of
          1: UIEditCloth;
          2: UIEditClothType;
          3: ;
        else
          Writeln('Неверный выбор.');
        end;
      end;

      8:
      begin
        ShowSpecialMenu;
        Readln(sub);
        case sub of
          1: UISelectGoods;
          2: UIBuyGoods;
          3: ;
        else
          Writeln('Неверный выбор.');
        end;
      end;

      9:
      begin
        Writeln('Внимание: несохранённые изменения будут потеряны!');
        Write('Выйти без сохранения? (д/н): ');
        Readln(confirm);
        if (confirm = 'д') or (confirm = 'Д') or
           (confirm = 'y') or (confirm = 'Y') then
        begin
          Writeln('Выход без сохранения.');
          Running := False;
        end
        else
          Writeln('Выход отменён.');
      end;

      10:
      begin
        SaveToFiles;
        Writeln('Выход с сохранением.');
        Running := False;
      end;

    else
      Writeln('Неверный пункт меню.');
    end;
  end;

  Writeln('Программа завершена.');
end;

end.
