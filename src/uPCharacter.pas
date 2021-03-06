//Unit for declaration of player character. Only heroes or normal enemies.
unit uPCharacter;

{/***************************************************************************
                          uPCharacter.pas  -  description
                             -------------------
    begin                : Wed Jan 28 2014
    copyright            : (C) 2014 by Enrique Fuentes
    email                : deejaykike@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 }

interface

uses
  uCharacter,
  uDice,
  uAttribs,
  uWeapon,
  uArmour,
  uInventoryType,
  SysUtils;

type

//Common character classes.
TClasse = (Fighter, Paladin, Ranger, Mage, Cleric, Druid, Thief, Bard);
//Common character races.
TRace = (Human, Dwarf, Elf, HalfElf, Halfling, Gnome);
//Class for player character.
TPCharacter = class(TCharacter)
  private
    fStr: TStrengthAttrib ;
    fDex: TDexterityAttrib ;
    fCon: TConstitutionAttrib ;
    fInt: TIntelligenceAttrib ;
    fWis: TWisdomAttrib ;
    fCha: TCharismaAttrib ;
    fDexACAdj, fConHPAdj: Integer;
    fRace: TRace;
    fClass: TClasse;
    fLevel, fXPEarned: Integer;
    function GetClass: string;
    function GetRace: string;
    function HitPoints: Integer;
    function checkClass(aClass: TClasse): Boolean;
    function verifyRace(aRace: TRace): Boolean;
    function verifyClass(aClass: TClasse): Boolean;
    function GetTHACO : Integer; virtual;
    class function min(x,y: Integer): Integer; static;
    class function max(x,y: Integer): Integer; static;
  public
    constructor Create(IntendedRace: TRace; IntendedClass: TClasse; initialWeapon: TWeapon; initialArmour: TArmour; startingLevel: Integer; Name: string);
    function GetAC: Integer; overload; virtual;
    property THACO: Integer read GetTHACO;
    property ClassName: string read GetClass;
    property RaceName: string read GetRace;
    function GetAC(const DamageType: Integer): Integer; overload; virtual;
    function doDamage(const Target: TCharacter): Integer; virtual;
    function haveClass: Boolean;
    function earnXP(amount: Integer): Integer;
end;

implementation

class function TPCharacter.min(x,y: Integer): Integer;
begin
  if x < y then Result:=x
  else Result:=y;
end;
class function TPCharacter.max(x,y: Integer): Integer;
begin
  if x > y then Result:=x
  else Result:=y;
end;

constructor TPCharacter.Create(IntendedRace: TRace; IntendedClass: TClasse; initialWeapon: TWeapon; initialArmour: TArmour; startingLevel: Integer; Name: string);
var
  c: Integer;
begin
  inherited Create(initialWeapon,initialArmour,Name);
  fStr:=TStrengthAttrib.Create(0);
  fDex:=TDexterityAttrib.Create(0);
  fCha:=TCharismaAttrib.Create(0);
  fCon:=TConstitutionAttrib.Create(0);
  fInt:=TIntelligenceAttrib.Create(0);
  fWis:=TWisdomAttrib.Create(0);
  fstr.Current:=TDice.Dice(3,6,0);
  fdex.Current:=TDice.Dice(3,6,0);
  fcon.Current:=TDice.Dice(3,6,0);
  fInt.Current:=TDice.Dice(3,6,0);
  fWis.Current:=TDice.Dice(3,6,0);
  fCha.Current:=TDice.Dice(3,6,0);
  fStr.MakeNormal;
  fDex.MakeNormal;
  fCon.MakeNormal;
  fInt.MakeNormal;
  fWis.MakeNormal;
  fCha.MakeNormal;
  if not verifyRace(IntendedRace) then fRace:=Human
  else fRace:=IntendedRace;
  if not checkClass(IntendedClass) then fClass:=Fighter
  else fClass:=IntendedClass;
  fLevel:=startingLevel;
  fXPEarned:=0;
  for c := 0 to fLevel do HitPoints;
end;

function TPCharacter.GetClass : string;
begin
  case fClass of
    Fighter: Result:='Fighter';
    Paladin: Result:='Paladin';
    Ranger: Result:='Ranger';
    Mage: Result:='Mage';
    Cleric: Result:='Cleric';
    Druid: Result:='Druid';
    Thief: Result:='Thief';
    Bard: Result:='Bard';
  end;
end;

function TPCharacter.GetRace : string;
begin
  case fRace of
    Human: Result:='Human';
    Dwarf: Result:='Dwarf';
    Elf: Result:='Elf';
    HalfElf: Result:='HalfElf';
    Halfling: Result:='Halfling';
    Gnome: Result:='Gnome';
  end;

end;

function TPCharacter.GetTHACO;
begin
  Result:=inherited THACO + fStr.getHitAdj;
end;

function TPCharacter.GetAC(const DamageType: Integer): Integer;
begin
  Result:=pArmour.getAC(TDamageTypes(DamageType)) + fDex.dexACMod;
end;

function TPCharacter.GetAC: Integer;
begin

  Result:=inherited GetAC  + fDex.dexACMod;
end;

function TPCharacter.doDamage(const Target: TCharacter): Integer;
var
  Damage: Integer;
begin
  Damage:=pWeapon.returnDamage + fStr.getDamAdj;
  Target.LoseHP(Damage);
  Result:=Damage;
end;

function TPCharacter.checkClass(aClass: TClasse): Boolean;
begin
  case aClass of
    Fighter: Result:=True ;
    Paladin: Result:=fRace = TRace.Human;
    Ranger: Result:=(fRace = TRace.Human) or (fRace = TRace.Elf) or (fRace = TRace.HalfElf) ;
    Mage: Result:=(fRace = TRace.Human) or (fRace = TRace.Elf) or (fRace = TRace.HalfElf) ;
    Cleric: Result:=True ;
    Druid: Result:=(fRace = TRace.Human) or (fRace = TRace.Elf) ;
    Thief: Result:=True ;
    Bard: ;
  end;

end;

function TPCharacter.haveClass: Boolean;
begin
  Result:=True;
end;

function TPCharacter.verifyRace(aRace: TRace): Boolean;
begin
  case aRace of
    Human: Result:=True;
    Dwarf:
    begin
      fCon.Current:=Max(11, fCon.Current);
      fStr.Current:=Max(8,fStr.Current);
      fCha.Current:=Min(17,fCha.Current);
      fCon.Incr(1);
      fCha.Decr(1);
      fCon.MakeNormal;
      fStr.MakeNormal;
      fCha.MakeNormal;
      Result:=True;
    end;
    Elf:
    begin
      fDex.Current:=Max(6, fDex.Current);
      fDex.MakeNormal;
      fCon.Current:=Max(7, fCon.Current);
      fCon.MakeNormal;
      fInt.Current:=Max(8, fInt.Current);
      fInt.MakeNormal;
      fCha.Current:=Max(8, fCha.Current);
      fCha.MakeNormal;
      Result:=True;
    end;
    HalfElf:
    begin
      fDex.Current:=Max(6, fDex.Current);
      fCon.Current:=Max(6, fCon.Current);
      fInt.Current:=Max(6, fInt.Current);
      fDex.MakeNormal;
      fCon.MakeNormal;
      fInt.MakeNormal;
      Result:=True;
    end;
    Halfling:
    begin
      fStr.Current:=max(7, fStr.Current);
      fDex.Current:=max(7, fDex.Current);
      fCon.Current:=max(10, fCon.Current);
      fInt.Current:=max(6, fInt.Current);
      fWis.Current:=min(17, fWis.Current);
      fDex.Incr(1);
      fStr.Decr(1);
      fStr.MakeNormal;
      fDex.MakeNormal;
      fCon.MakeNormal;
      fint.MakeNormal;
      fWis.MakeNormal;
      Result:=True;
    end;
    Gnome:
    begin
      fStr.Current:=max(6, fStr.Current);
      fCon.Current:=max(8, fCon.Current);
      fInt.Current:=max(4, fint.Current);
      fCon.MakeNormal;
      fDex.MakeNormal;
      fint.MakeNormal;
      Result:=True;
    end;
    else result:=False;
  end;


end;

function TPCharacter.verifyClass(aClass: TClasse): Boolean;
begin
  case aClass of
    Fighter:
    begin
      fStr.Current:=max(9, fStr.Current);
      fStr.MakeNormal;
    end;
    Paladin:
    begin
      fCon.Current:=Max(9, fCon.Current);
      fStr.Current:=Max(12,fStr.Current);
      fWis.Current:=Max(13,fWis.Current);
      fCha.Current:=Min(17,fCha.Current);
      fCon.MakeNormal;
      fStr.MakeNormal;
      fCha.MakeNormal;
      Result:=True;
    end;
    Ranger:
    begin
      fStr.Current:=Max(13,fStr.Current);
      fStr.MakeNormal;
      fDex.Current:=Max(13,fDex.Current);
      fDex.MakeNormal;
      fCon.Current:=Max(14,fCon.Current);
      fCon.MakeNormal;
      fWis.Current:=Max(14,fWis.Current);
      fWis.MakeNormal;
      Result:=True;
    end;
    Mage:
    begin
      fInt.Current:=Max(9, fInt.Current);
      fInt.MakeNormal;
      Result:=True;
    end;
    Cleric:
    begin
      fWis.Current:=min(9, fWis.Current);
      fWis.MakeNormal;
      Result:=True;
    end;
    Druid:
    begin
      fWis.Current:=min(12, fWis.Current);
      fWis.MakeNormal;
      fCha.Current:=Min(15,fCha.Current);
      fCha.MakeNormal;
      Result:=True;
    end;
    Thief:
    begin
      fDex.Current:=min(9, fDex.Current);
      fDex.MakeNormal;
      Result:=True;
    end;
    Bard:
    begin
      fDex.Current:=min(12, fDex.Current);
      fDex.MakeNormal;
      fInt.Current:=Max(13, fInt.Current);
      fInt.MakeNormal;
      fCha.Current:=Min(15,fCha.Current);
      fCha.MakeNormal;
      Result:=True;
    end;
    else result:=False;
  end;
end;

function TPCharacter.HitPoints: Integer;
begin
  case fClass of
    Fighter: Result:=TDice.Dice(1,10,fConHPAdj);
    Paladin: Result:=TDice.Dice(1,10,fConHPAdj);
    Ranger: Result:=TDice.Dice(1,10,fConHPAdj);
    Mage: Result:=TDice.Dice(1,4,fConHPAdj);
    Cleric: Result:=TDice.Dice(1,8,fConHPAdj);
    Druid: Result:=TDice.Dice(1,8,fConHPAdj);
    Thief: Result:=TDice.Dice(1,6,fConHPAdj);
    Bard: Result:=TDice.Dice(1,6,fConHPAdj);
    else Result:=TDice.Dice(1,7,fConHPAdj);
  end;
  pHP.ChangeMax(Result);
  pHP.Current:=1000000;
end;

function TPCharacter.earnXP(amount: Integer): Integer;
begin
  Inc(fXPEarned,Amount);
  Result:=fXPEarned;
end;


end.
