unit Utils;


interface

// Читает целое число. Если ввод не является числом — Ok = False
procedure ReadInt(const Prompt: string; var Result: Integer; var Ok: Boolean);

// Проверка на ввод вещественного числа
procedure ReadReal(const Prompt: string; var Result: Real; var Ok: Boolean);

// Проверка на ввод строки
procedure ReadStr(const Prompt: string; var Result: string; var Ok: Boolean);

implementation

procedure ReadInt(const Prompt: string; var Result: Integer; var Ok: Boolean);
var
  s: string;
  code: Integer;
begin
  Write(Prompt);
  Readln(s);
  Val(s, Result, code);
  Ok := code = 0;
  if not Ok then
    Writeln('Ошибка ввода: ожидается целое число.');
end;

procedure ReadReal(const Prompt: string; var Result: Real; var Ok: Boolean);
var
  s: string;
  code: Integer;
begin
  Write(Prompt);
  Readln(s);
  Val(s, Result, code);
  Ok := code = 0;
  if not Ok then
    Writeln('Ошибка ввода: ожидается вещественное число.');
end;

procedure ReadStr(const Prompt: string; var Result: string; var Ok: Boolean);
begin
  Write(Prompt);
  Readln(Result);
  Ok := Result <> '';
  if not Ok then
    Writeln('Ошибка ввода: строка не должна быть пустой.');
end;

end.

