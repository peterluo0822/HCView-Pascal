{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{               �ĵ������Ӧ�Ļ��ƶ���                  }
{                                                       }
{*******************************************************}

unit HCDrawItem;

interface

uses
  Windows, Classes;

type
  TDrawOption = (doLineFirst, doLineLast, doParaFirst);
  TDrawOptions = set of TDrawOption;  //(doLineFrist, doParaFrist);

  THCCustomDrawItem = class(TPersistent)
  private
    FOptions: TDrawOptions;
  protected
    function GetLineFirst: Boolean;
    procedure SetLineFirst(const Value: Boolean);
    function GetParaFirst: Boolean;
    procedure SetParaFirst(const Value: Boolean);
  public
    ItemNo,    // ��Ӧ��Item
    CharOffs,  // ��1��ʼ
    CharLen   // ��CharOffs��ʼ���ַ�����
    //DrawLeft,  // ����ʱ��Ļ������
    //DrawRight  // ����ʱ��Ļ������
      : Integer;
    //CharSpace: Single;  // ��ɢ��������˶���ʱ�����ַ�������
    //RemWidth,  // �������Ҳ����
    //RemHeight, // �����и߶Ȳ�һ�µ�DItemʱ���ײ�������ⲹ�����
    //FmtTopOffset
    //  : Integer;
    Rect: TRect;  // ���ĵ��еĸ�ʽ������
    //
    function CharOffsetEnd: Integer;
    function Width: Integer;
    function Height: Integer;
    property LineFirst: Boolean read GetLineFirst write SetLineFirst;
    property ParaFirst: Boolean read GetParaFirst write SetParaFirst;
  end;

  THCDrawItems = class(TList)  { TODO : ��Ϊ��List��ʵ�� }
  private
    // ��ʽ����ز���
    FDeleteStartDrawItemNo,
    FDeleteCount,
    FFormatBeforBottom: Integer;
    function GetItem(Index: Integer): THCCustomDrawItem;
    procedure SetItem(Index: Integer; const Value: THCCustomDrawItem);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    /// <summary> �ڸ�ʽ��ǰ���Ҫɾ������ʼ�ͽ���DrawItemNo </summary>
    procedure MarkFormatDelete(const AStartDrawItemNo, AEndDrawItemNo: Integer);

    /// <summary> ɾ����ʽ��ǰ��ǵ���ʼ�ͽ���DrawItemNo </summary>
    procedure DeleteFormatMark;

    /// <summary> ��ʼ����ʽ������ </summary>
    procedure ClearFormatMark;
    procedure DeleteRange(const AIndex, ACount: Integer);
    procedure Insert(const AIndex: Integer; const AItem: THCCustomDrawItem);
    function Last: THCCustomDrawItem;
    property Items[Index: Integer]: THCCustomDrawItem read GetItem write SetItem; default;

    /// <summary> ��ʽ��ǰ��Ӧ��DrawItem�ײ�λ�� </summary>
    property FormatBeforBottom: Integer read FFormatBeforBottom write FFormatBeforBottom;
  end;

implementation

{ THCCustomDrawItem }

function THCCustomDrawItem.GetLineFirst: Boolean;
begin
  Result := doLineFirst in FOptions;
end;

function THCCustomDrawItem.GetParaFirst: Boolean;
begin
  Result := doParaFirst in FOptions;
end;

function THCCustomDrawItem.Height: Integer;
begin
  Result := Rect.Bottom - Rect.Top;
end;

function THCCustomDrawItem.CharOffsetEnd: Integer;
begin
  Result := CharOffs + CharLen - 1;
end;

procedure THCCustomDrawItem.SetLineFirst(const Value: Boolean);
begin
  if Value then
    Include(FOptions, doLineFirst)
  else
    Exclude(FOptions, doLineFirst);
end;

procedure THCCustomDrawItem.SetParaFirst(const Value: Boolean);
begin
  if Value then
    Include(FOptions, doParaFirst)
  else
    Exclude(FOptions, doParaFirst);
end;

function THCCustomDrawItem.Width: Integer;
begin
  Result := Rect.Right - Rect.Left;
end;

{ THCDrawItems }

procedure THCDrawItems.ClearFormatMark;
begin
  FDeleteStartDrawItemNo := -1;
  FDeleteCount := 0;
  FFormatBeforBottom := -1;
end;

procedure THCDrawItems.DeleteFormatMark;
begin
  Self.DeleteRange(FDeleteStartDrawItemNo, FDeleteCount);
  FDeleteStartDrawItemNo := -1;
  FDeleteCount := 0;
end;

procedure THCDrawItems.DeleteRange(const AIndex, ACount: Integer);
var
  i, vEndIndex: Integer;
begin
  if ACount <> 0 then
  begin
    vEndIndex := AIndex + ACount - 1;
    if vEndIndex > Self.Count - 1 then
      vEndIndex := Self.Count - 1;
    for i := vEndIndex downto AIndex do
      Delete(i);
  end;
end;

function THCDrawItems.GetItem(Index: Integer): THCCustomDrawItem;
begin
  Result := THCCustomDrawItem(inherited Get(Index));
end;

procedure THCDrawItems.Insert(const AIndex: Integer; const AItem: THCCustomDrawItem);
begin
  if FDeleteCount = 0 then
    inherited Insert(AIndex, AItem)
  else
  begin
    Assert(AIndex = FDeleteStartDrawItemNo);
    Inc(FDeleteStartDrawItemNo);
    Dec(FDeleteCount);
    Items[AIndex] := AItem;
  end;
end;

function THCDrawItems.Last: THCCustomDrawItem;
begin
  Result := GetItem(Self.Count - 1);
end;

procedure THCDrawItems.MarkFormatDelete(const AStartDrawItemNo, AEndDrawItemNo: Integer);
begin
  FDeleteStartDrawItemNo := AStartDrawItemNo;
  FDeleteCount := AEndDrawItemNo - AStartDrawItemNo + 1;
end;

procedure THCDrawItems.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = TListNotification.lnDeleted then
    THCCustomDrawItem(Ptr).Free;
  inherited;
end;

procedure THCDrawItems.SetItem(Index: Integer; const Value: THCCustomDrawItem);
begin
  inherited Put(Index, Value);
end;

end.