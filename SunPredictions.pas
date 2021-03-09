unit SunPredictions;

interface

uses SysUtils, Math, DateUtils, TimeSpan;

type
  TSunTimes = (stAstronomical, stNautic, stCivil, stOfficial);

  TSunPosition = class
  private const
    fDefaultLatitude = 50.827847;  // Chemnitz
    fDefaultLongitude = 12.921370; //

    fOfficial = 90 + (50 / 60);
    fCivil = 96.0;
    fNautic = 102.0;
    fAstronomical = 108.0;
  public type
    TSunTimesRec = record
    private
      function GetRaw(Index: TSunTimes): TDateTime;
    public

    property Times[Index: TSunTimes]: TDateTime read GetRaw; default;

    case Byte of
    0: (Astronomical,
       Nautic,
       Civil,
       Official: TDateTime);
    1: (Raw: array[TSunTimes] of TDateTime);
    end;
  private
    class var fYesterday: TSunPosition;
    class var fToday: TSunPosition;
    class var fTomorrow: TSunPosition;

    class constructor Create;
    class destructor Destroy;
    class function GetYesterday: TSunPosition; static;
    class function GetToday: TSunPosition; static;
    class function GetTomorrow: TSunPosition; static;
  public
    class property Yesterday: TSunPosition read GetYesterday;
    class property Today: TSunPosition read GetToday;
    class property Tomorrow: TSunPosition read GetTomorrow;
  private
    fRiseTime: TSunTimesRec;
    fSetTime: TSunTimesRec;
    fDate: TDateTime;

    function GetSunTimes(Date: TDate; Latitude, Longitude: Double; Sunrise: Boolean): TSunTimesRec;
  public
    constructor Create(Date: TDateTime; Latitude: Double = fDefaultLatitude; Longitude: Double = fDefaultLongitude);

    function RiseDuration(SunTime: TSunTimes): TTime;
    function SetDuration(SunTime: TSunTimes): TTime;

    property RiseTime: TSunTimesRec read fRiseTime;
    property SetTime: TSunTimesRec read fSetTime;
    property Date: TDateTime read fDate;
  end;

implementation

{$REGION 'TSunPosition'}

function TSunPosition.GetSunTimes(Date: TDate; Latitude, Longitude: Double; Sunrise: Boolean): TSunTimesRec;
  procedure BringToRange(var Value: Double; Lower, Upper: Double);
  begin
    while not InRange(Value, Lower, Upper) do
    begin
      if Value < Lower then
        Value := Value + Upper;
      if Value >= Upper then
        Value := Value - Upper;
    end;
  end;

const
  DToR = Pi / 180;
  RtoD = 180 / Pi;
var
  N: Word;
  lngHour, t, M, L, RA, Lquadrant, RAquadrant, sinDec, cosDec, Td: Double;

  function GetUTFromZenith(Zenith: Double): Double;
  var
    cosH, H, Ti: Double;
  begin
    cosH := (cos(DToR * zenith) - (sinDec * sin(DToR * latitude))) / (cosDec * cos(DToR * latitude));

    if (cosH > 1) and Sunrise then exit(0);
    if (cosH < -1) and not Sunrise then exit(0);
    if Sunrise then
      H := 360 - RToD * arccos(cosH)
    else
      H := RToD * arccos(cosH);

    H := H / 15;

    Ti := H + RA - (0.06571 * t) - 6.622;
    Result := Ti - lngHour;
    BringToRange(Result, 0, 24);
  end;

  function TimeToHMRange(tt: TDateTime): TDateTime;
  begin
    Result := RecodeTime(tt, RecodeLeaveFieldAsIs, RecodeLeaveFieldAsIs, 0, 0);
  end;

begin
  N := DayOfTheYear(Date);
  lngHour := Longitude / 15;
  if Sunrise then
    t := N + ((6 - lngHour) / 24)
  else
    t := N + ((18 - lngHour) / 24);

  M := (0.9856 * t) - 3.289;
  L := M + (1.916 * sin(DtoR * M)) + (0.020 * sin(2 * M * DtoR)) + 282.634;
  BringToRange(L, 0, 360);
  RA := RToD * ArcTan(0.91764 * tan(DToR * L));
  BringToRange(RA, 0, 360);
  Lquadrant  := (floor(L / 90)) * 90;
	RAquadrant := (floor(RA / 90)) * 90;
	RA := RA + (Lquadrant - RAquadrant);
  RA := RA / 15;
  sinDec := 0.39782 * sin(L * DToR);
	cosDec := cos(RToD * ArcSin(sinDec * DToR));
  with Result do
  begin
    Td := Date;
    Astronomical := Td + TimeToHMRange(GetUTFromZenith(fAstronomical) / 24) + TTimeZone.Local.UtcOffset;
    Nautic := Td + TimeToHMRange(GetUTFromZenith(fNautic) / 24) + TTimeZone.Local.UtcOffset;
    Civil := Td + TimeToHMRange(GetUTFromZenith(fCivil) / 24) + TTimeZone.Local.UtcOffset;
    Official := Td + TimeToHMRange(GetUTFromZenith(fOfficial) / 24) + TTimeZone.Local.UtcOffset;
  end;
end;

class constructor TSunPosition.Create;
begin
  fYesterday := TSunPosition.Create(SysUtils.Date - 1);
  fToday := TSunPosition.Create(SysUtils.Date);
  fTomorrow := TSunPosition.Create(SysUtils.Date + 1);
end;

constructor TSunPosition.Create(Date: TDateTime; Latitude, Longitude: Double);
begin
  fRiseTime := GetSunTimes(Date, Latitude, Longitude, true);
  fSetTime := GetSunTimes(Date, Latitude, Longitude, false);
  fDate := Date;
end;

class destructor TSunPosition.Destroy;
begin
  fYesterday.Free;
  fToday.Free;
  fTomorrow.Free;
end;

class function TSunPosition.GetToday: TSunPosition;
begin
  if Trunc(fToday.Date) <> Trunc(SysUtils.Date) then
  begin
    fToday.Free;
    fToday := TSunPosition.Create(SysUtils.Date);
  end;
  Result := fToday;
end;

class function TSunPosition.GetTomorrow: TSunPosition;
begin
  if Trunc(fTomorrow.Date) <> Trunc(SysUtils.Date + 1) then
  begin
    fTomorrow.Free;
    fTomorrow := TSunPosition.Create(SysUtils.Date + 1);
  end;
  Result := fTomorrow;
end;

class function TSunPosition.GetYesterday: TSunPosition;
begin
  if Trunc(fYesterday.Date) <> Trunc(SysUtils.Date - 1) then
  begin
    fYesterday.Free;
    fYesterday := TSunPosition.Create(SysUtils.Date - 1);
  end;
  Result := fYesterday;
end;

function TSunPosition.RiseDuration(SunTime: TSunTimes): TTime;
begin
  Result := fRiseTime[SunTime] - fRiseTime.Official;
end;

function TSunPosition.SetDuration(SunTime: TSunTimes): TTime;
begin
  Result := fSetTime[SunTime] - fSetTime.Official;
end;

{$ENDREGION}

{$REGION 'TSunPosition.TSunTimesRec'}

function TSunPosition.TSunTimesRec.GetRaw(Index: TSunTimes): TDateTime;
begin
  Result := Raw[Index];
end;

{$ENDREGION}

end.
