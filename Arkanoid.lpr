program Arkanoid;

uses
  CRT,
  SDL,
  SDL_TTF,
  SysUtils,
  Classes;

const
  GRA_1P = 1;
  //Gra jednoosobowa
  //GRA_2P = 2;
  //Gra dwóch graczy, gracza z komputerem lub komputera z komputerem
  ILOSC_KLOCKOW = 500;
  ILOSC_KLOCKOW_2 = 494; //Plansza dla 2 graczy 494 - domyslne
  OPOZNIENIE = 0;
  ILOSC_BONUSOW = 400;
  t_WYBUCH = 600;
  MIN_DLUGOSC = 120;
  t_PRZENIKANIE = 600;
  MAX_PREDKOSC = 7;
  MIN_PREDKOSC = 1;

var
  ekran, k_ziel, k_czer, k_zolt, k_nieb, k_bonu, paletka, tlo, pilka,
  napis, k_pusty, {bonus,} wybor, tlo_menu, bonus_1, bonus_2, bonus_3,
  bonus_4, bonus_5, bonus_6, bonus_7, bonus_8, zycie, win_1, win_2, koniec: pSDL_Surface;
  pos_k, klocek, paletka_wsp, pos_p, pos_p_2, paletka_wsp_2, tlo_wsp,
  pos_tlo, pos_pilka, pilka_wsp, pos_napis, bonus_wsp, pos_bonus,
  wybor_wsp, pos_wybor, pos_tlo_menu, tlo_menu_wsp, zycie_wsp, pos_zycie, pos_win, win_wsk: pSDL_Rect;
  //*_wsp - wczytywanie tekstur, pos_* - wyswietlanie tekstur
  ruch, menu: pSDL_Event;
  czcionka: pTTF_FONT;
  kolor_czcionki: pSDL_COLOR;
  plansza_1P: array [1..1000] of integer;
  bonusy: array [1..ILOSC_BONUSOW] of array [1..4] of integer;
  //1 - typ(1 - wybuch, 2 - w_d+), 2 - pos_x, 3 - pos_y, 4 - dy
  wybuchanie: array[1..2] of integer;                  //1 - aktywnosc, 2 - czas trwania
  przenikanie: array[1..2] of integer;
  i, x, y, w_d, w_d_2, p_p, p_p_2, prawo, prawo_2, lewo, lewo_2,
  gra_trwa, typ_gry, ruch_pilki, x_p, y_p, ruch_gracza_1, ruch_gracza_2,
  punkty_1, punkty_2, licznik_punktow, licznik_bonusow, a, PREDKOSC_PALETKI,
  PREDKOSC_PALETKI_2, spacja_SI, test_1, test_2, liczba_zyc_1,
  liczba_zyc_2, magnes_1, magnes_2, t_magnes_1, t_magnes_2: integer;
  tmp: extended; //a - losowa liczba do bonusow, tmp - pozycja pilki wzgledem paletki
  //i - licznik petli x,y - wspolrzedne wyswietlanie klocka w_d - szerokosc domyslna
  //w_d - domyslna szerokosc paletki, p_p - pozycja paletki na planszy (od lewego gornego rogu!!)
  //prawo,lewo - ruch paletki PIERWSZEGO GRACZA (NA DOLE)
  //ruch pilki - pilka porusza sie jezeli wartosc przyjmuje jeden, do wykorzystania prze magnesie
  //x_p, y_p - wspolrzedne pilki, wczytywane do pos_pilka
  //gra_trwa - odpowiada za wykonywanie petli gry
  //typ_gry - odpowiada ze rodzaj gry(1 - jeden gracz, 2 - dwoch graczy, 3 - gracz vs CPU)
  //*_2 - Drugi gracz/CPU

  //Uruchamianie SDL, ustawianie rozdzielczosci, hardware
  procedure Inicjalizacja_SDL();
  begin
    SDL_INIT(SDL_INIT_VIDEO);
    SDL_SHOWCURSOR(SDL_DISABLE);
    SDL_WM_SetCaption('ARKANOID', nil);
    TTF_INIT();
    //SDL_putenv('SDL_VIDEODRIVER=directx');
    ekran := SDL_SETVIDEOMODE(1000, 600, 32, SDL_HWSURFACE or
      SDL_DOUBLEBUF or SDL_ASYNCBLIT{ or SDL_FULLSCREEN});
  end;
  //zamykanie SDL
  procedure Wylacz_gre();
  begin
    dispose(czcionka);
    dispose(kolor_czcionki);
    dispose(pos_napis);
    dispose(pos_p);
    dispose(pos_p_2);
    dispose(paletka_wsp);
    dispose(paletka_wsp_2);
    dispose(klocek);
    dispose(pos_k);
    dispose(tlo);
    dispose(tlo_wsp);
    dispose(pos_tlo);
    dispose(pos_pilka);
    dispose(pilka_wsp);
    dispose(bonus_wsp);
    dispose(pos_bonus);
    dispose(ruch);
    dispose(menu);
    dispose(wybor_wsp);
    dispose(pos_wybor);
    dispose(tlo_menu_wsp);
    dispose(pos_tlo_menu);
    SDL_FREESURFACE(k_bonu);
    SDL_FREESURFACE(k_ziel);
    SDL_FREESURFACE(k_czer);
    SDL_FREESURFACE(k_nieb);
    SDL_FREESURFACE(k_zolt);
    SDL_FREESURFACE(k_pusty);
    SDL_FREESURFACE(napis);
    SDL_FREESURFACE(paletka);
    SDL_FREESURFACE(tlo);
    SDL_FREESURFACE(pilka);
    SDL_FREESURFACE(napis);
    //SDL_FREESURFACE(bonus);
    SDL_FREESURFACE(wybor);
    SDL_FREESURFACE(tlo_menu);
    SDL_FREESURFACE(bonus_1);
    SDL_FREESURFACE(bonus_2);
    SDL_FREESURFACE(bonus_3);
    SDL_FREESURFACE(bonus_4);
    SDL_FREESURFACE(bonus_5);
    SDL_FREESURFACE(bonus_6);
    SDL_FREESURFACE(ekran);
    TTF_QUIT();
    SDL_QUIT();
  end;
  //zapelnianie planszy
  procedure Zapelnianie_planszy();
  begin
    randomize;
    for i := ILOSC_KLOCKOW downto 1 do
      plansza_1p[i] := random(5) + 1;   //nieb,czerw,ziel,zolty
    for i := 1 to ILOSC_BONUSOW do
    begin
      plansza_1p[random(ILOSC_KLOCKOW_2)] := 6;
    end;
  end;
  //Zapelnia plansze dla 2 graczy
  procedure Zapelnianie_planszy_2();
  begin
    randomize;
    for i := ILOSC_KLOCKOW_2 downto 1 do
      plansza_1p[i] := random(5) + 1;   //nieb,czerw,ziel,zolty
    for i := 1 to ILOSC_BONUSOW do
    begin
      plansza_1p[random(ILOSC_KLOCKOW_2)] := 6;
    end;
  end;
  //Wczytuje tekstury klockow, domyslne pozycje, reguly rysowania
  procedure Wczytanie_tekstur();
  begin
    new(czcionka);
    new(kolor_czcionki);
    new(pos_napis);
    new(pos_p);
    new(pos_p_2);
    new(paletka_wsp);
    new(paletka_wsp_2);
    new(klocek);
    new(pos_k);
    new(tlo);
    new(tlo_wsp);
    new(pos_tlo);
    new(pos_pilka);
    new(pilka_wsp);
    new(bonus_wsp);
    new(pos_bonus);
    new(ruch);
    new(menu);
    new(wybor_wsp);
    new(pos_wybor);
    new(tlo_menu_wsp);
    new(pos_tlo_menu);
    new(pos_zycie);
    new(zycie_wsp);
    new(pos_win);
    new(win_wsk);
    koniec := SDL_LoadBMP('Textures\koniec.bmp');
    win_1:= SDL_LoadBMP('Textures\win_1.bmp');
    win_2:= SDL_LoadBMP('Textures\win_2.bmp');
    bonus_1 := SDL_LoadBMP('Textures\b_wyb.bmp');
    bonus_2 := SDL_LoadBMP('Textures\w_d+.bmp');
    bonus_3 := SDL_LoadBMP('Textures\w_d-.bmp');
    bonus_4 := SDL_LoadBMP('Textures\pos_p+.bmp');
    bonus_5 := SDL_LoadBMP('Textures\pos_p-.bmp');
    bonus_6 := SDL_LoadBMP('Textures\b_p.bmp');
    bonus_7 := SDL_LoadBMP('Textures\zycie+.bmp');
    bonus_8 := SDL_LoadBMP('Textures\magnes.bmp');
    tlo_menu := SDL_LoadBMP('Textures\tlo_menu.bmp');
    zycie := SDL_LoadBMP('Textures\zycie.bmp');
    k_ziel := SDL_LoadBMP('Textures\k_ziel.bmp');
    k_nieb := SDL_LoadBMP('Textures\k_nieb.bmp');
    k_zolt := SDL_LoadBMP('Textures\k_zolt.bmp');
    k_czer := SDL_LoadBMP('Textures\k_czer.bmp');
    k_pusty := SDL_LoadBMP('Textures\k_pusty.bmp');
    k_bonu := SDL_LoadBMP('Textures\k_bonu.bmp');
    paletka := SDL_LoadBMP('Textures\paletka.bmp');
    tlo := SDL_LoadBMP('Textures\tlo.bmp');
    pilka := SDL_LoadBMP('Textures\pilka.bmp');
    czcionka := TTF_OpenFont('calibri.ttf', 22);
    kolor_czcionki^.r := 255;
    kolor_czcionki^.g := 255;
    kolor_czcionki^.b := 255;
    pos_win^.x := 0;
    pos_win^.y := 0;
    pos_win^.w := 801;
    pos_win^.h := 600;
    win_wsk^.x := 0;
    win_wsk^.y := 0;
    win_wsk^.w := 801;
    win_wsk^.h := 600;
    zycie_wsp^.x := 0;
    zycie_wsp^.y := 0;
    zycie_wsp^.w := 35;
    zycie_wsp^.h := 35;
    pos_zycie^.w := 35;
    pos_zycie^.h := 35;
    pos_napis^.w := 200;
    pos_napis^.h := 30;
    bonus_wsp^.x := 0;
    bonus_wsp^.y := 0;
    bonus_wsp^.h := 10;
    bonus_wsp^.w := 10;
    pos_bonus^.h := 10;
    pos_bonus^.w := 10;
    tlo_wsp^.x := 0;
    tlo_wsp^.y := 0;
    tlo_wsp^.h := 600;
    tlo_wsp^.w := 1000;
    tlo_menu_wsp^.x := 0;
    tlo_menu_wsp^.y := 0;
    tlo_menu_wsp^.h := 600;
    tlo_menu_wsp^.w := 1000;
    wybor_wsp^.x := 0;
    wybor_wsp^.y := 0;
    wybor_wsp^.h := 40;
    wybor_wsp^.w := 355;
    pos_wybor^.h := 40;
    pos_wybor^.w := 355;
    pilka_wsp^.x := 0;      //TEST
    pilka_wsp^.y := 0;
    pilka_wsp^.w := 10;
    pilka_wsp^.h := 10;
    pos_pilka^.x := 425;   //TEST
    pos_pilka^.y := 578;
    pos_pilka^.w := 10;
    pos_pilka^.h := 10;
    pos_p^.x := p_p_2;        //pozycja paletki
    pos_p^.y := 588;        //const
    pos_p^.w := w_d;
    pos_p^.h := 12;         //const
    pos_p_2^.x := p_p;        //pozycja paletki
    pos_p_2^.y := 0;        //const
    pos_p_2^.w := w_d_2;
    pos_p_2^.h := 12;         //const
    paletka_wsp^.x := 0;
    paletka_wsp^.y := 0;
    paletka_wsp^.w := w_d;
    //nalezy do przedzialu 150-300, poczatkowa wartosc deklarowana w main!!!
    paletka_wsp^.h := 12;
    paletka_wsp_2^.x := 0;
    paletka_wsp_2^.y := 0;
    paletka_wsp_2^.w := w_d_2;
    //nalezy do przedzialu 150-300, poczatkowa wartosc deklarowana w main!!!
    paletka_wsp_2^.h := 12;
    pos_k^.x := x;          //w funkcji rysowanie!
    pos_k^.y := y;          //w funkcji rysowanie!
    pos_k^.w := 32;
    pos_k^.h := 12;
    klocek^.x := 0;
    klocek^.y := 0;
    klocek^.w := 32;
    klocek^.h := 12;
    pos_tlo^.x := 0;
    pos_tlo^.y := 0;
    pos_tlo^.w := 1000;
    pos_tlo^.h := 600;
    pos_tlo_menu^.x := 0;
    pos_tlo_menu^.y := 0;
    pos_tlo_menu^.w := 1000;
    pos_tlo_menu^.h := 600;
  end;
  //Wykonanie ruchu przez SI
  procedure RuchSI();
  begin
    if typ_Gry = 3 then
    begin
      //randomize;
      //test_1:=random(20)+70;
      LEWO_2 := 0;
      PRAWO_2 := 0;
      test_2 := (w_d_2 div 2) - 3 + random(6);
      if ((pos_pilka^.x < (pos_p_2^.x + test_2 + 1)) and (pos_pilka^.y < 250) and
        (pos_p_2^.x > 0) and (pos_p_2^.x > 0 + predkosc_paletki_2)) then
        LEWO_2 := 1
      else if ((pos_pilka^.x > (pos_p_2^.x + test_2 + 1)) and (pos_pilka^.y < 250) and
        (pos_p_2^.x < 800 + w_d_2) and (pos_p_2^.x < 800 - predkosc_paletki_2 - w_d_2)) then
        PRAWO_2 := 1
      else if ((pos_pilka^.x > 400) and (pos_pilka^.y > 300)) then
      begin
        if ((pos_p_2^.x > 400) and (pos_p_2^.x > 400 + predkosc_paletki_2)) then
          LEWO_2 := 1
        else if ((pos_p_2^.x < 400) and (pos_p_2^.x < 400 - predkosc_paletki_2)) then
          PRAWO_2 := 1;
      end
      else if ((pos_pilka^.x < 400 - w_d_2) and (pos_pilka^.y > 300)) then
      begin
        if ((pos_p_2^.x > 400 - w_d_2) and (pos_p_2^.x > 400 - w_d_2 + predkosc_paletki_2)) then
          LEWO_2 := 1
        else if ((pos_p_2^.x < 400 - w_d_2) and
          (pos_p_2^.x < 400 - w_d_2 - predkosc_paletki_2)) then
          PRAWO_2 := 1;
      end;
    end;
    if typ_Gry = 4 then
    begin
      LEWO_2 := 0;
      PRAWO_2 := 0;
      //tmp:=(pos_p_2^.x+w_d_2)/2;
      test_2 := (w_d_2 div 2) - 3 + random(6);
      test_1 := (w_d div 2) - 3 + random(6);
      if ((pos_pilka^.x < (pos_p_2^.x + test_2 + 1)) and (pos_pilka^.y < 300) and
        (pos_p_2^.x > 0) and (pos_p_2^.x > 0 + predkosc_paletki_2)) then
        LEWO_2 := 1
      else if ((pos_pilka^.x > (pos_p_2^.x + test_2 + 1)) and (pos_pilka^.y < 300) and
        (pos_p_2^.x < 800 + w_d_2) and (pos_p_2^.x < 800 - predkosc_paletki_2 - w_d_2)) then
        PRAWO_2 := 1
      else if ((pos_pilka^.x > 400) and (pos_pilka^.y > 300)) then
      begin
        if ((pos_p_2^.x > 400) and (pos_p_2^.x > 400 + predkosc_paletki_2)) then
          LEWO_2 := 1
        else if ((pos_p_2^.x < 400) and (pos_p_2^.x < 400 - predkosc_paletki_2)) then
          PRAWO_2 := 1;
      end
      else if ((pos_pilka^.x < 400 - w_d_2) and (pos_pilka^.y > 300)) then
      begin
        if ((pos_p_2^.x > 400 - w_d_2) and (pos_p_2^.x > 400 - w_d_2 + predkosc_paletki_2)) then
          LEWO_2 := 1
        else if ((pos_p_2^.x < 400 - w_d_2) and
          (pos_p_2^.x < 400 - w_d_2 - predkosc_paletki_2)) then
          PRAWO_2 := 1;
      end;
      LEWO := 0;
      PRAWO := 0;
      if ((pos_pilka^.x < (pos_p^.x + test_1 + 1)) and (pos_pilka^.y > 300) and
        (pos_p^.x > 0) and (pos_p^.x > 0 + predkosc_paletki)) then
        LEWO := 1
      else if ((pos_pilka^.x > (pos_p^.x + test_1 + 1)) and (pos_pilka^.y > 300) and
        (pos_p^.x < 800 + w_d) and (pos_p^.x < 800 - predkosc_paletki - w_d)) then
        PRAWO := 1
      else if ((pos_pilka^.x > 400) and (pos_pilka^.y < 300)) then
      begin
        if ((pos_p^.x > 400) and (pos_p^.x > 400 + predkosc_paletki)) then
          LEWO := 1
        else if ((pos_p^.x < 400) and (pos_p^.x < 400 - predkosc_paletki)) then
          PRAWO := 1;
      end
      else if ((pos_pilka^.x < 400 - w_d) and (pos_pilka^.y < 300)) then
      begin
        if ((pos_p^.x > 400 - w_d) and (pos_p^.x > 400 - w_d + predkosc_paletki)) then
          LEWO := 1
        else if ((pos_p^.x < 400 - w_d) and (pos_p^.x < 400 - w_d - predkosc_paletki)) then
          PRAWO := 1;
      end;
    end;
  end;
  //Funkcja odpowiedzialna za wczytywanie klawiszy z klawiatury
  procedure Wczytywanie_klawiszy();
  begin
    case ruch^.type_ of
      SDL_KEYDOWN:
      begin
        if (ruch^.key.keysym.sym = SDLK_LEFT) then
        begin
          LEWO := 1;
          PRAWO := 0;
        end
        else if (ruch^.key.keysym.sym = SDLK_RIGHT) then
        begin
          PRAWO := 1;
          LEWO := 0;
        end
        else if (ruch^.key.keysym.sym = SDLK_ESCAPE) then
          gra_trwa := 0;
        if ((ruch^.key.keysym.sym = SDLK_A) and (typ_gry = 2)) then
        begin
          LEWO_2 := 1;
          PRAWO_2 := 0;
        end
        else if ((ruch^.key.keysym.sym = SDLK_D) and (typ_gry = 2)) then
        begin
          LEWO_2 := 0;
          PRAWO_2 := 1;
        end;
      end;
      SDL_KEYUP:
      begin
        if (ruch^.key.keysym.sym = SDLK_LEFT) then
        begin
          LEWO := 0;
        end
        else if (ruch^.key.keysym.sym = SDLK_RIGHT) then
        begin
          PRAWO := 0;
        end;
        if ((ruch^.key.keysym.sym = SDLK_A) and (typ_gry = 2)) then
        begin
          LEWO_2 := 0;
        end
        else if ((ruch^.key.keysym.sym = SDLK_D) and (typ_gry = 2)) then
        begin
          PRAWO_2 := 0;
        end;
      end;
    end;
  end;
  //Rysuje plansze do gry;
  procedure Rysuj_plansze();
  begin
  {pos_p^.y := 588;      TEST
  pos_p^.h := 12;
  paletka_wsp^.x := 0;
  paletka_wsp^.y := 0;
  paletka_wsp^.h := 12;
  pos_k^.w := 32;
  pos_k^.h := 12;
  klocek^.x := 0;
  klocek^.y := 0;
  klocek^.w := 32;
  klocek^.h := 12;
  pos_tlo^.x := 0;
  pos_tlo^.y := 0;
  pos_tlo^.w := 1000;
  pos_tlo^.h := 600;    TEST}
    x := 0;
    y := 0;
    SDL_BlitSurface(tlo, tlo_wsp, ekran, pos_tlo);
    pos_napis^.x := 830;
    pos_napis^.y := 400;
    napis := TTF_RenderText_Blended(czcionka, 'Wynik Gracza 1:', kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
   sdl_freesurface(napis);
    pos_napis^.x := 895;
    pos_napis^.y := 440;
    napis := TTF_RenderText_Blended(czcionka, PChar(IntToStr(punkty_1)),
      kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
   sdl_freesurface(napis);
    pos_zycie^.x := 865;
    pos_zycie^.y := 340;
    SDL_BlitSurface(zycie, zycie_wsp, ekran, pos_zycie);
    pos_napis^.x := 900;
    pos_napis^.y := 355;
     napis := TTF_RenderText_Blended(czcionka, 'x', kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 910;
    pos_napis^.y := 355;
    napis := TTF_RenderText_Blended(czcionka, PChar(IntToStr(liczba_zyc_1)),
      kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    for i := 1 to ILOSC_KLOCKOW do
    begin
      pos_k^.x := x;
      pos_k^.y := y;
      if (plansza_1p[i] = 1) then
      begin
        SDL_BlitSurface(k_ziel, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 2) then
      begin
        SDL_BlitSurface(k_nieb, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 3) then
      begin
        SDL_BlitSurface(k_czer, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 4) then
      begin
        SDL_BlitSurface(k_zolt, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 6) then
      begin
        SDL_BlitSurface(k_bonu, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 0) then
      begin
        SDL_BlitSurface(k_pusty, klocek, ekran, pos_k);
      end;
      x := x + 32;
      if (i mod 25 = 0) then
      begin
        x := 0;
        y := y + 12;
      end;
    end;
    for i := 1 to ILOSC_BONUSOW do
    begin
      if ((bonusy[i][1] = 1) or (bonusy[i][1] = 2) or (bonusy[i][1] = 3) or
        (bonusy[i][1] = 4) or (bonusy[i][1] = 5) or (bonusy[i][1] = 6) or
        (bonusy[i][1] = 7) or (bonusy[i][1] = 8)) then
      begin
        pos_bonus^.x := bonusy[i][2];
        pos_bonus^.y := bonusy[i][3];
        bonusy[i][3] := bonusy[i][3] + bonusy[i][4];
        if (bonusy[i][1] = 1) then
        begin
          //bonus := SDL_LoadBMP('Textures\b_wyb.bmp');
          SDL_BlitSurface(bonus_1, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 2) then
        begin
          //bonus := SDL_LoadBMP('Textures\w_d+.bmp');
          SDL_BlitSurface(bonus_2, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 3) then
        begin
          //bonus := SDL_LoadBMP('Textures\w_d-.bmp');
          SDL_BlitSurface(bonus_3, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 4) then
        begin
          //bonus := SDL_LoadBMP('Textures\pos_p+.bmp');
          SDL_BlitSurface(bonus_4, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 5) then
        begin
          // bonus := SDL_LoadBMP('Textures\pos_p-.bmp');
          SDL_BlitSurface(bonus_5, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 6) then
        begin
          // bonus := SDL_LoadBMP('Textures\b_p.bmp');
          SDL_BlitSurface(bonus_6, bonus_wsp, ekran, pos_bonus);
          // sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 7) then
        begin
          // bonus := SDL_LoadBMP('Textures\b_p.bmp');
          SDL_BlitSurface(bonus_7, bonus_wsp, ekran, pos_bonus);
          // sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 8) then
        begin
          // bonus := SDL_LoadBMP('Textures\b_p.bmp');
          SDL_BlitSurface(bonus_8, bonus_wsp, ekran, pos_bonus);
          // sdl_freesurface(bonus);
        end;
      end;
    end;
  end;
  //Rysuje plansze dla 2 graczy
  procedure Rysuj_plansze_2();
  begin
    x := 96;
    y := 144;
    SDL_BlitSurface(tlo, tlo_wsp, ekran, pos_tlo);
    pos_napis^.x := 830;
    pos_napis^.y := 100;
    napis := TTF_RenderText_Blended(czcionka, 'Wynik Gracza 2:', kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 895;
    pos_napis^.y := 140;
    napis := TTF_RenderText_Blended(czcionka, PChar(IntToStr(punkty_2)),
      kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 830;
    pos_napis^.y := 400;
    napis := TTF_RenderText_Blended(czcionka, 'Wynik Gracza 1:', kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 895;
    pos_napis^.y := 440;
    napis := TTF_RenderText_Blended(czcionka, PChar(IntToStr(punkty_1)),
      kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    SDL_BlitSurface(paletka, paletka_wsp, ekran, pos_p);
    SDL_BlitSurface(paletka, paletka_wsp_2, ekran, pos_p_2);
    pos_k^.x := 801;
    pos_k^.y := 0;
    SDL_BlitSurface(k_pusty, klocek, ekran, pos_k);
    pos_k^.x := 801;
    pos_k^.y := 588;
    SDL_BlitSurface(k_pusty, klocek, ekran, pos_k);
    pos_zycie^.x := 865;
    pos_zycie^.y := 40;
    SDL_BlitSurface(zycie, zycie_wsp, ekran, pos_zycie);
    pos_zycie^.x := 865;
    pos_zycie^.y := 340;
    SDL_BlitSurface(zycie, zycie_wsp, ekran, pos_zycie);
    pos_napis^.x := 900;
    pos_napis^.y := 55;
    napis := TTF_RenderText_Blended(czcionka, 'x', kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 910;
    pos_napis^.y := 55;
    napis := TTF_RenderText_Blended(czcionka, PChar(IntToStr(liczba_zyc_2)),
      kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 900;
    pos_napis^.y := 355;
    napis := TTF_RenderText_Blended(czcionka, 'x', kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    pos_napis^.x := 910;
    pos_napis^.y := 355;
    napis := TTF_RenderText_Blended(czcionka, PChar(IntToStr(liczba_zyc_1)),
      kolor_czcionki^);
    SDL_BLITSURFACE(napis, nil, ekran, pos_napis);
    sdl_freesurface(napis);
    for i := 1 to ILOSC_KLOCKOW_2 do
    begin
      pos_k^.x := x;
      pos_k^.y := y;
      if (plansza_1p[i] = 1) then
      begin
        SDL_BlitSurface(k_ziel, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 2) then
      begin
        SDL_BlitSurface(k_nieb, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 3) then
      begin
        SDL_BlitSurface(k_czer, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 4) then
      begin
        SDL_BlitSurface(k_zolt, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 0) then
      begin
        SDL_BlitSurface(k_pusty, klocek, ekran, pos_k);
      end
      else if (plansza_1p[i] = 6) then
      begin
        SDL_BlitSurface(k_bonu, klocek, ekran, pos_k);
      end;
      x := x + 32;
      if (i mod 19 = 0) then
      begin
        x := 96;
        y := y + 12;
      end;
    end;
    for i := 1 to ILOSC_BONUSOW do
    begin
      if ((bonusy[i][1] = 1) or (bonusy[i][1] = 2) or (bonusy[i][1] = 3) or
        (bonusy[i][1] = 4) or (bonusy[i][1] = 5) or (bonusy[i][1] = 6) or
        (bonusy[i][1] = 7) or (bonusy[i][1] = 8)) then
      begin
        pos_bonus^.x := bonusy[i][2];
        pos_bonus^.y := bonusy[i][3];
        bonusy[i][3] := bonusy[i][3] + bonusy[i][4];
        if (bonusy[i][1] = 1) then
        begin
          //bonus := SDL_LoadBMP('Textures\b_wyb.bmp');
          SDL_BlitSurface(bonus_1, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 2) then
        begin
          //bonus := SDL_LoadBMP('Textures\w_d+.bmp');
          SDL_BlitSurface(bonus_2, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 3) then
        begin
          //bonus := SDL_LoadBMP('Textures\w_d-.bmp');
          SDL_BlitSurface(bonus_3, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 4) then
        begin
          //bonus := SDL_LoadBMP('Textures\pos_p+.bmp');
          SDL_BlitSurface(bonus_4, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 5) then
        begin
          //bonus := SDL_LoadBMP('Textures\pos_p-.bmp');
          SDL_BlitSurface(bonus_5, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 6) then
        begin
          //bonus := SDL_LoadBMP('Textures\b_p.bmp');
          SDL_BlitSurface(bonus_6, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 7) then
        begin
          //bonus := SDL_LoadBMP('Textures\b_p.bmp');
          SDL_BlitSurface(bonus_7, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end
        else if (bonusy[i][1] = 8) then
        begin
          //bonus := SDL_LoadBMP('Textures\b_p.bmp');
          SDL_BlitSurface(bonus_8, bonus_wsp, ekran, pos_bonus);
          //sdl_freesurface(bonus);
        end;
      end;
    end;
    SDL_BlitSurface(pilka, pilka_wsp, ekran, pos_pilka);
    sdl_flip(ekran);
  end;
  //Dodaje bonus do kostki ze znakiem zapytania
  procedure Dodaj_bonus();
  begin
    if (Plansza_1P[i] = 6) then
    begin
      randomize;
      repeat
        a := random(8) + 1
      until ((a = 1) or (a = 2) or (a = 3) or (a = 4) or (a = 5) or
          (a = 6) or (a = 7) or (a = 8));
      bonusy[licznik_bonusow][1] := a; //random(0) - rodzaje bonusów, losowe;
      bonusy[licznik_bonusow][2] := x + 12;
      bonusy[licznik_bonusow][3] := y + 6;
      if (ruch_gracza_1 = 1) then
        bonusy[licznik_bonusow][4] := (1);      //kierunki spadania bonusow;
      if (ruch_gracza_2 = 1) then
        bonusy[licznik_bonusow][4] := (-1);
      licznik_bonusow := licznik_bonusow + 1;
    end;
  end;
  //Funkcja wybuchu dla 1 gracza
  procedure wybuch_1();
  begin
    if (wybuchanie[1] = 1) then
    begin
      if (i mod 25 = 0) then
      begin
        if ((i + 1) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 25) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 25] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 26) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 26] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 25) > 0) then
        begin
          Plansza_1P[i - 25] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 24) > 0) then
        begin
          Plansza_1P[i - 24] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
      end
      else if (i mod 24 = 0) then
      begin
        if ((i - 1) > 0) then
        begin
          Plansza_1P[i - 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 25) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 25] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 24) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 24] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        begin
          Plansza_1P[i - 26] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 25) > 0) then
        begin
          Plansza_1P[i - 25] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
      end
      else if ((i mod 25 <> 0) and (i mod 26 <> 0)) then
      begin
        if ((i + 1) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 1) > 0) then
        begin
          Plansza_1P[i - 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 25) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 25] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 26) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 26] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 24) < ILOSC_KLOCKOW) then
        begin
          Plansza_1P[i + 24] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 25) > 0) then
        begin
          Plansza_1P[i - 25] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 26) > 0) then
        begin
          Plansza_1P[i - 26] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 24) > 0) then
        begin
          Plansza_1P[i - 24] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
      end;
    end;
  end;
  //Wykrywanie zderzen w grze dla 1 gracza //fixed
  procedure Wykrywanie_kolizji();
  begin
    x := 0;
    y := 0;
    i := 1;
    while (i <= ILOSC_KLOCKOW) do
    begin
      begin
        if ((Plansza_1P[i] = 1) or (Plansza_1P[i] = 2) or (Plansza_1P[i] = 3) or
          (Plansza_1P[i] = 4) or (Plansza_1P[i] = 6)) then
          //6 - bonusy test, dorobic osobne warunki {wywolywane odpowiednie funkce, fixed}
        begin
          if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y + 11 = y)) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;
          end
          else if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y - 1 = y + 12)) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y + 11 = y)) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y - 1 = y + 12)) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;
          end
          else if ((pos_pilka^.y - 1 = y + 12) and (pos_pilka^.x >= x) and
            (pos_pilka^.x <= (x + 32))) then
          begin
            //W RAZIE POTRZEBY PRZY BONUSACH
            //ZAMENIC pos_pilka^.y - 1
            //NA pos_pilka^.y - y_p
            //DOLNA KRAWEDZ KLOCKA
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;
          end
          else if ((pos_pilka^.y - 1 = y + 12) and (pos_pilka^.x + 10 >= x) and
            (pos_pilka^.x <= (x + 32))) then
          begin
            //W RAZIE POTRZEBY PRZY BONUSACH
            //ZAMENIC pos_pilka^.y - 1
            //NA pos_pilka^.y - y_p
            //DOLNA KRAWEDZ KLOCKA
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;
          end
          else if ((pos_pilka^.y + 11 = y) and (pos_pilka^.x + 10 >= x) and
            (pos_pilka^.x + 10 <= (x + 42))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;//GORNA KRAWEDZ KLOCKA
          end
          else {TEST - fixed} if ((pos_pilka^.y + 11 = y) and
            (pos_pilka^.x >= x) and (pos_pilka^.x <= (x + 42))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW;//GORNA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y >= y) and
            (pos_pilka^.y <= (y + 12))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW;//PRAWA KRAWEDZ KLOCKA
          end
          else {TEST - fixed}if ((pos_pilka^.x - 1 = x + 32) and
            (pos_pilka^.y + 10 >= y) and (pos_pilka^.y + 10 <= (y + 12))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW;//PRAWA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y + 10 >= y) and
            (pos_pilka^.y + 10 <= (y + 12))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW;//PRAWA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y >= y) and
            (pos_pilka^.y <= (y + 12))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW;//LEWA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y + 10 >= y) and
            (pos_pilka^.y + 10 <= (y + 12))) then
          begin
            Dodaj_bonus();
            wybuch_1();
            Plansza_1P[i] := 0;
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW;//LEWA KRAWEDZ KLOCKA
          end;
        end;
      end;
      x := x + 32;
      if (i mod 25 = 0) then
      begin
        x := 0;
        y := y + 12;
      end;
      Inc(i);
    end;
    {if ((pos_pilka^.y + 11 = 588) and (pos_pilka^.x > pos_p^.x) and
      (pos_pilka^.x < (pos_p^.x + w_d))) then begin
      y_p := 0 - y_p;
      ruch_gracza_1:=1;
      end;}
    if ((pos_pilka^.y - 1 = 1)) then
      y_p := 0 - y_p;
    if ((pos_pilka^.y + 11 = 588) and (pos_pilka^.x > pos_p^.x) and
      (pos_pilka^.x < (pos_p^.x + w_d)) and (magnes_1 = 0)) then
    begin
      tmp := pos_p^.x + (w_d / 2);
      if ((pos_pilka^.x > tmp) and (x_p > 0)) then
        x_p := x_p
      else if ((pos_pilka^.x > tmp) and (x_p < 0)) then
        x_p := 0 - x_p
      else if ((pos_pilka^.x < tmp) and (x_p < 0)) then
        x_p := x_p
      else if ((pos_pilka^.x < tmp) and (x_p > 0)) then
        x_p := 0 - x_p;
      y_p := 0 - y_p;
      ruch_gracza_1 := 1;
    end
    else if ((pos_pilka^.y + 11 = 588) and (pos_pilka^.x > pos_p^.x) and
      (pos_pilka^.x < (pos_p^.x + w_d)) and (magnes_1 = 1)) then
      ruch_pilki := 0;
    if (pos_pilka^.x - 1 = 0) then
      x_p := 0 - x_p
    //else if (pos_pilka^.y+1=590) then y_p:=0-y_p //TEST
    else if (pos_pilka^.x + 1 = 790) then
      x_p := 0 - x_p
    else if (pos_pilka^.y + 1 = 590) then
    begin
      pos_pilka^.y := 578;
      pos_pilka^.x := pos_p^.x + 75;
      ruch_gracza_1 := 1;
      ruch_pilki := 0;
      dec(liczba_zyc_1);
    end;
    for i := 1 to ILOSC_BONUSOW do
    begin
      if ((bonusy[i][1] = 1) or (bonusy[i][1] = 2) or (bonusy[i][1] = 3) or
        (bonusy[i][1] = 4) or (bonusy[i][1] = 5) or (bonusy[i][1] = 6) or
        (bonusy[i][1] = 7) or (bonusy[i][1] = 8)) then
      begin
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 1)) then
        begin
          bonusy[i][1] := 0;
          wybuchanie[1] := 1;
          wybuchanie[2] := t_WYBUCH;
          sdl_freesurface(pilka);
          pilka := SDL_LoadBMP('Textures\pilka_w.bmp');
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 2)) then
        begin
          bonusy[i][1] := 0;
          if (w_d < (300 - 32)) then
          begin
            pos_p^.x := pos_p^.x - 32;
            w_d := w_d + 32;
          end;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 3)) then
        begin
          bonusy[i][1] := 0;
          if (w_d > MIN_DLUGOSC) then
            w_d := w_d - 32;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 4)) then
        begin
          bonusy[i][1] := 0;
          if (predkosc_paletki <= MAX_PREDKOSC) then
            predkosc_paletki := predkosc_paletki + 1;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 5)) then
        begin
          bonusy[i][1] := 0;
          if (predkosc_paletki > MIN_PREDKOSC) then
            predkosc_paletki := predkosc_paletki - 1;
        end;
        if ((bonusy[i][3] - 1 = 10) and (bonusy[i][1] = 1)) then
          bonusy[i][1] := 0;
        if ((bonusy[i][3] + 11 = 590) and (bonusy[i][1] = 1)) then
          bonusy[i][1] := 0;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 6)) then
        begin
          bonusy[i][1] := 0;
          przenikanie[1] := 1;
          przenikanie[2] := t_PRZENIKANIE;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 7)) then
        begin
          bonusy[i][1] := 0;
          Inc(liczba_zyc_1);
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 8)) then
        begin
          magnes_1 := 1;
          t_magnes_1 := 5;
        end;
      end;
      if (bonusy[i][1] = 0) then
      begin
        bonusy[i][2] := 0;
        bonusy[i][3] := 0;
        bonusy[i][4] := 0;
      end;
    end;
  end;
  //Jezeli zostal zebrany bonus wybuchanie, przy wykrywaniu kolizji wykonywana jest funkcja DZIALA TYLKO DLA 2 GRACZY, //fixed
  procedure wybuch();
  begin
    if (wybuchanie[1] = 1) then
    begin
      if ((i = 20) or (i = 1) or (i = 39) or (i = 58) or (i = 77) or
        (i = 96) or (i = 115) or (i = 134) or (i = 153) or (i = 172) or
        (i = 191) or (i = 210) or (i = 229) or (i = 248) or (i = 267) or
        (i = 286) or (i = 305) or (i = 324) or (i = 343) or (i = 362) or
        (i = 381) or (i = 400) or (i = 419) or (i = 438) or (i = 457) or (i = 476)) then
      begin
        if ((i + 1) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 19) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 19] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 20) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 20] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 19) > 0) then
        begin
          Plansza_1P[i - 19] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 18) > 0) then
        begin
          Plansza_1P[i - 18] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
      end
      else if (i mod 19 = 0) then
      begin
        if ((i - 1) > 0) then
        begin
          Plansza_1P[i - 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 19) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 19] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 18) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 18] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        begin
          Plansza_1P[i - 20] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 19) > 0) then
        begin
          Plansza_1P[i - 19] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
      end
      else if ((i mod 19 <> 0) and (i mod 20 <> 0)) then
      begin
        if ((i + 1) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 1) > 0) then
        begin
          Plansza_1P[i - 1] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 19) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 19] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 20) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 20] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i + 18) < ILOSC_KLOCKOW_2) then
        begin
          Plansza_1P[i + 18] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 19) > 0) then
        begin
          Plansza_1P[i - 19] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 20) > 0) then
        begin
          Plansza_1P[i - 20] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
        if ((i - 18) > 0) then
        begin
          Plansza_1P[i - 18] := 0;
          licznik_punktow := licznik_punktow + 1;
        end;
      end;
    end;
  end;
  //Wykrywa wszystkie mozliwe zderenia w grze dla 2 graczy
  procedure Wykrywanie_kolizji_2();
  begin
    licznik_punktow := 0;
    x := 96;
    y := 144;
    i := 1;
    while (i <= ILOSC_KLOCKOW_2) do
    begin
      begin
        if ((Plansza_1P[i] = 1) or (Plansza_1P[i] = 2) or (Plansza_1P[i] = 3) or
          (Plansza_1P[i] = 4) or (Plansza_1P[i] = 6)) then
          //6 - bonusy test, dorobic osobne warunki {wywolywane odpowiednie funkce, fixed}
        begin
          if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y + 11 = y)) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;
          end
          else if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y - 1 = y + 12)) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y + 11 = y)) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y - 1 = y + 12)) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;
          end
          else if ((pos_pilka^.y - 1 = y + 12) and (pos_pilka^.x >= x) and
            (pos_pilka^.x <= (x + 32))) then
          begin
            //W RAZIE POTRZEBY PRZY BONUSACH
            //ZAMENIC pos_pilka^.y - 1
            //NA pos_pilka^.y - y_p
            //DOLNA KRAWEDZ KLOCKA
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;
          end
          else if ((pos_pilka^.y - 1 = y + 12) and (pos_pilka^.x + 10 >= x) and
            (pos_pilka^.x <= (x + 32))) then
          begin
            //W RAZIE POTRZEBY PRZY BONUSACH
            //ZAMENIC pos_pilka^.y - 1
            //NA pos_pilka^.y - y_p
            //DOLNA KRAWEDZ KLOCKA
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;
          end
          else if ((pos_pilka^.y + 11 = y) and (pos_pilka^.x + 10 >= x) and
            (pos_pilka^.x + 10 <= (x + 42))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;//GORNA KRAWEDZ KLOCKA
          end
          else {TEST - fixed} if ((pos_pilka^.y + 11 = y) and
            (pos_pilka^.x >= x) and (pos_pilka^.x <= (x + 42))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              y_p := 0 - y_p;
            end;
            i := ILOSC_KLOCKOW_2;//GORNA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y >= y) and
            (pos_pilka^.y <= (y + 12))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW_2;//PRAWA KRAWEDZ KLOCKA
          end
          else {TEST - fixed}if ((pos_pilka^.x - 1 = x + 32) and
            (pos_pilka^.y + 10 >= y) and (pos_pilka^.y + 10 <= (y + 12))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW_2;//PRAWA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x - 1 = x + 32) and (pos_pilka^.y + 10 >= y) and
            (pos_pilka^.y + 10 <= (y + 12))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW_2;//PRAWA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y >= y) and
            (pos_pilka^.y <= (y + 12))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW_2;//LEWA KRAWEDZ KLOCKA
          end
          else if ((pos_pilka^.x + 11 = x) and (pos_pilka^.y + 10 >= y) and
            (pos_pilka^.y + 10 <= (y + 12))) then
          begin
            Dodaj_bonus();
            Plansza_1P[i] := 0;
            wybuch();
            licznik_punktow := licznik_punktow + 1;
            if (przenikanie[1] = 0) then
            begin
              x_p := 0 - x_p;
            end;
            i := ILOSC_KLOCKOW_2;//LEWA KRAWEDZ KLOCKA
          end;
        end;
      end;
      x := x + 32;
      if (i mod 19 = 0) then
      begin
        x := 96;
        y := y + 12;
      end;
      Inc(i);
    end;
    if ((pos_pilka^.y + 11 = 588) and (pos_pilka^.x > pos_p^.x) and
      (pos_pilka^.x < (pos_p^.x + w_d)) and (magnes_1 = 0)) then
    begin
      tmp := pos_p^.x + (w_d / 2);
      if ((pos_pilka^.x > tmp) and (x_p > 0)) then
        x_p := x_p
      else if ((pos_pilka^.x > tmp) and (x_p < 0)) then
        x_p := 0 - x_p
      else if ((pos_pilka^.x < tmp) and (x_p < 0)) then
        x_p := x_p
      else if ((pos_pilka^.x < tmp) and (x_p > 0)) then
        x_p := 0 - x_p;
      y_p := 0 - y_p;
      ruch_gracza_1 := 1;
      ruch_gracza_2 := 0;
    end;
    if ((pos_pilka^.y + 11 = 588) and (pos_pilka^.x > pos_p^.x) and
      (pos_pilka^.x < (pos_p^.x + w_d)) and (magnes_1 = 1)) then
    begin
      ruch_pilki := 0;
      ruch_gracza_1 := 1;
      ruch_gracza_2 := 0;
    end;
    if ((pos_pilka^.y - 1 = 0) and (typ_gry = 1)) then
      y_p := 0 - y_p
    else if (pos_pilka^.x - 1 = 0) then
      x_p := 0 - x_p
    else if (pos_pilka^.y + 1 = 590) then
    begin
      pos_pilka^.y := 12; //Pilka dla przeciwnika!
      pos_pilka^.x := pos_p_2^.x + (w_d_2 div 2);
      ruch_gracza_2 := 1;
      ruch_gracza_1 := 0;
      ruch_pilki := 0;
      Dec(liczba_zyc_1);
      if (typ_gry = 3) then
        spacja_SI := 1;
    end
    else if (pos_pilka^.y - 1 = 0) then
    begin
      pos_pilka^.y := 578; //Pilka dla przeciwnika!
      pos_pilka^.x := pos_p^.x + (w_d div 2);
      ruch_gracza_2 := 0;
      ruch_gracza_1 := 1;
      ruch_pilki := 0;
      Dec(liczba_zyc_2);
    end
    else if (pos_pilka^.x + 1 = 790) then
      x_p := 0 - x_p;
    if ((pos_pilka^.y - 1 = 12) and (pos_pilka^.x > pos_p_2^.x) and
      (pos_pilka^.x < (pos_p_2^.x + w_d_2)) and (magnes_2 = 0)) then
    begin
      tmp := pos_p_2^.x + (w_d_2 / 2);
      if ((pos_pilka^.x > tmp) and (x_p > 0)) then
        x_p := x_p
      else if ((pos_pilka^.x > tmp) and (x_p < 0)) then
        x_p := 0 - x_p
      else if ((pos_pilka^.x < tmp) and (x_p < 0)) then
        x_p := x_p
      else if ((pos_pilka^.x < tmp) and (x_p > 0)) then
        x_p := 0 - x_p;
      y_p := 0 - y_p;
      ruch_gracza_1 := 0;
      ruch_gracza_2 := 1;
    end;
    if ((pos_pilka^.y - 1 = 12) and (pos_pilka^.x > pos_p_2^.x) and
      (pos_pilka^.x < (pos_p_2^.x + w_d_2)) and (magnes_2 = 1)) then
    begin
      ruch_pilki := 0;
      ruch_gracza_1 := 0;
      ruch_gracza_2 := 1;
    end;
    {kolizje bonusow z paletka}
    for i := 1 to ILOSC_BONUSOW do
    begin
      if ((bonusy[i][1] = 1) or (bonusy[i][1] = 2) or (bonusy[i][1] = 3) or
        (bonusy[i][1] = 4) or (bonusy[i][1] = 5) or (bonusy[i][1] = 6) or
        (bonusy[i][1] = 7) or (bonusy[i][1] = 8)) then
      begin
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 1)) then
        begin
          bonusy[i][1] := 0;
          wybuchanie[1] := 1;
          wybuchanie[2] := t_WYBUCH;
          sdl_freesurface(pilka);
          pilka := SDL_LoadBMP('Textures\pilka_w.bmp');
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] - 1 = pos_p_2^.y + 12) and (bonusy[i][1] = 1)) then
        begin
          bonusy[i][1] := 0;
          wybuchanie[1] := 1;
          wybuchanie[2] := t_WYBUCH;
          sdl_freesurface(pilka);
          pilka := SDL_LoadBMP('Textures\pilka_w.bmp');
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 2)) then
        begin
          bonusy[i][1] := 0;
          if (w_d < (300 - 32)) then
          begin
            pos_p^.x := pos_p^.x - 32;
            w_d := w_d + 32;
          end;
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] + 11 = pos_p_2^.y + 12) and (bonusy[i][1] = 2)) then
        begin
          if (w_d_2 < (300 - 32)) then
          begin
            pos_p_2^.x := pos_p_2^.x - 32;
            w_d_2 := w_d_2 + 32;
          end;
          bonusy[i][1] := 0;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 3)) then
        begin
          bonusy[i][1] := 0;
          if (w_d > MIN_DLUGOSC) then
            w_d := w_d - 32;
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] + 11 = pos_p_2^.y + 12) and (bonusy[i][1] = 3)) then
        begin
          if (w_d_2 > MIN_DLUGOSC) then
            w_d_2 := w_d_2 - 32;
          bonusy[i][1] := 0;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 4)) then
        begin
          bonusy[i][1] := 0;
          if (predkosc_paletki <= MAX_PREDKOSC) then
            predkosc_paletki := predkosc_paletki + 1;
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] + 11 = pos_p_2^.y + 12) and (bonusy[i][1] = 4)) then
        begin
          bonusy[i][1] := 0;
          if (predkosc_paletki_2 <= MAX_PREDKOSC) then
            predkosc_paletki_2 := predkosc_paletki_2 + 1;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 5)) then
        begin
          bonusy[i][1] := 0;
          if (predkosc_paletki > MIN_PREDKOSC) then
            predkosc_paletki := predkosc_paletki - 1;
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] + 11 = pos_p_2^.y + 12) and (bonusy[i][1] = 5)) then
        begin
          bonusy[i][1] := 0;
          if (predkosc_paletki_2 > MIN_PREDKOSC) then
            predkosc_paletki_2 := predkosc_paletki_2 - 1;
        end;
        if ((bonusy[i][3] - 1 = 10) and (bonusy[i][1] = 1)) then
          bonusy[i][1] := 0;
        if ((bonusy[i][3] + 11 = 590) and (bonusy[i][1] = 1)) then
          bonusy[i][1] := 0;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 6)) then
        begin
          bonusy[i][1] := 0;
          przenikanie[1] := 1;
          przenikanie[2] := t_PRZENIKANIE;
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] - 1 = pos_p_2^.y + 12) and (bonusy[i][1] = 6)) then
        begin
          bonusy[i][1] := 0;
          przenikanie[1] := 1;
          przenikanie[2] := t_PRZENIKANIE;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 7)) then
        begin
          bonusy[i][1] := 0;
          Inc(liczba_zyc_1);
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] - 1 = pos_p_2^.y + 12) and (bonusy[i][1] = 7)) then
        begin
          bonusy[i][1] := 0;
          Inc(liczba_zyc_2);
        end;
        if ((bonusy[i][2] > pos_p_2^.x) and (bonusy[i][2] < pos_p_2^.x + w_d_2) and
          (bonusy[i][3] - 1 = pos_p_2^.y + 12) and (bonusy[i][1] = 8)) then
        begin
          bonusy[i][1] := 0;
          if (typ_gry = 2) then
          begin
            magnes_2 := 1;
            t_magnes_2 := 5;
          end;
        end;
        if ((bonusy[i][2] > pos_p^.x) and (bonusy[i][2] < pos_p^.x + w_d) and
          (bonusy[i][3] + 11 = pos_p^.y) and (bonusy[i][1] = 8)) then
        begin
          bonusy[i][1] := 0;
          if ((typ_gry = 2) or (typ_gry = 3)) then
          begin
            magnes_1 := 1;
            t_magnes_1 := 5;
          end;
        end;
      end;
      if (bonusy[i][1] = 0) then
      begin
        bonusy[i][2] := 0;
        bonusy[i][3] := 0;
        bonusy[i][4] := 0;
      end;
    end;
  end;
  //Resetuje zmienne, polozenia pilki, paletek
  procedure resetowanie();
  begin
    ruch_pilki := 0;
    punkty_1 := 0;
    punkty_2 := 0;
    licznik_bonusow := 1;
    ruch_gracza_1 := 1;
    ruch_gracza_2 := 0;
    lewo := 0;
    prawo := 0;
    prawo_2 := 0;
    lewo_2 := 0;
    liczba_zyc_1 := 3;
    liczba_zyc_2 := 3;
    PREDKOSC_PALETKI := 3;
    PREDKOSC_PALETKI_2 := 3;
    magnes_1 := 0;
    magnes_2 := 0;
    t_magnes_1 := 0;
    t_magnes_2 := 0;
    if ((typ_gry = 3) or (typ_gry = 4)) then
      PREDKOSC_PALETKI_2 := 1;
    if typ_gry = 4 then
      PREDKOSC_PALETKI := 1;
    w_d := 150; //domyslna dlugosc paletki
    p_p := 350; //domyslna pozycja paletki
    w_d_2 := 150; //domyslna dlugosc paletki 2
    p_p_2 := 350; //domyslna pozycja paletki 2
    pos_pilka^.x := 425;   //TEST
    pos_pilka^.y := 578;
    pos_pilka^.w := 10;
    pos_pilka^.h := 10;
    pos_p^.x := p_p_2;        //pozycja paletki
    pos_p^.y := 588;        //const
    pos_p^.w := w_d;
    pos_p^.h := 12;         //const
    pos_p_2^.x := p_p;        //pozycja paletki
    pos_p_2^.y := 0;        //const
    pos_p_2^.w := w_d_2;
    pos_p_2^.h := 12;
    wybuchanie[1] := 0;
    przenikanie[1] := 0;
    sdl_freesurface(pilka);
    pilka := SDL_LoadBMP('Textures\pilka.bmp');
  end;
  //Petla gry dla 1 gracza
  procedure gra_1gracz();
  begin
    resetowanie();
    pos_pilka^.y := 577;
    zapelnianie_planszy();
    while (gra_trwa = GRA_1P) do
    begin
      pos_p^.x := p_p;
      pos_p^.w := w_d;
      paletka_wsp^.w := w_d;
      if (wybuchanie[1] = 1) then
      begin
        Dec(wybuchanie[2]);
        //konczy bonus, petla bonusu;
        if (wybuchanie[2] = 0) then
        begin
          wybuchanie[1] := 0;
          sdl_freesurface(pilka);
          pilka := SDL_LoadBMP('Textures\pilka.bmp');
        end;
      end;
      if (przenikanie[1] = 1) then
      begin
        Dec(przenikanie[2]);
        //konczy bonus, petla bonusu;
        if (przenikanie[2] = 0) then
        begin
          przenikanie[1] := 0;
        end;
      end;
      if SDL_POLLEVENT(ruch) = 1 then
        Wczytywanie_klawiszy();
      if (p_p >= (800 + predkosc_paletki - w_d)) then
      begin
        lewo := 0;
        prawo := 0;
        p_p := p_p - PREDKOSC_PALETKI;
      end
      else if (p_p - predkosc_paletki <= 0 - predkosc_paletki) then
      begin
        lewo := 0;
        prawo := 0;
        p_p := p_p + PREDKOSC_PALETKI;
      end;
        {if ((ruch_pilki = 0) and (lewo = 1)) then  //start pileczki w lewo
        begin
          x_p := (-1);
          y_p := (-1);
          //przesuwanie pilki, w razie potrzeby wywolac dwa razy z funkcja wykrywanie kolizi (bonus przyspieszania/zwalniania pileczki)
          pos_pilka^.x := pos_pilka^.x + x_p;
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_pilki := 1;
        end;
        if ((ruch_pilki = 0) and (prawo = 1)) then //start pileczki w prawo
        begin
          x_p := 1;
          y_p := (-1);
          pos_pilka^.x := pos_pilka^.x + x_p;
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_pilki := 1;
        end;}
      if ((ruch_pilki = 0) and (lewo = 1) and (ruch_gracza_1 = 1)) then
        //start pileczki w lewo
      begin
        x_p := (-1);

        pos_pilka^.x := pos_pilka^.x - PREDKOSC_PALETKI;
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          y_p := -1;
          //dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_gracza_2 := 0;
          ruch_gracza_1 := 1;
        end;
      end
      else if ((ruch_pilki = 0) and (prawo = 1) and (ruch_gracza_1 = 1)) then
        //start pileczki w prawo
      begin
        x_p := 1;
        pos_pilka^.x := pos_pilka^.x + PREDKOSC_PALETKI;
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          y_p := -1;
          //dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_gracza_2 := 0;
          ruch_gracza_1 := 1;
        end;
        //ruch_pilki := 1;
      end;
      if lewo = 1 then
        p_p := p_p - PREDKOSC_PALETKI
      else if prawo = 1 then
        p_p := p_p + PREDKOSC_PALETKI;
      if lewo_2 = 1 then
        p_p_2 := p_p_2 - PREDKOSC_PALETKI_2
      else if prawo_2 = 1 then
        p_p_2 := p_p_2 + PREDKOSC_PALETKI_2;
      if ((ruch_pilki = 0) and (pos_pilka^.x > 400) and (pos_pilka^.y > 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 1;
          ruch_gracza_2 := 0;
          y_p := -1;
          Dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if ((ruch_pilki = 0) and (pos_pilka^.x <= 400) and (pos_pilka^.y > 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 1;
          ruch_gracza_2 := 0;
          y_p := -1;
          Dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if ((ruch_pilki = 0) and (pos_pilka^.x > 400) and (pos_pilka^.y <= 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 0;
          ruch_gracza_2 := 1;
          y_p := 1;
          Dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if ((ruch_pilki = 0) and (pos_pilka^.x <= 400) and (pos_pilka^.y <= 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 0;
          ruch_gracza_2 := 1;
          y_p := 1;
          Dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if (ruch_pilki = 1) then
        pos_pilka^.x := pos_pilka^.x + x_p;
      //przesuwanie pilki, w razie potrzeby wywolac dwa razy z funkcja wykrywanie kolizi (bonus przyspieszania/zwalniania pileczki)
      if (ruch_pilki = 1) then
        pos_pilka^.y := pos_pilka^.y + y_p;
      Wykrywanie_kolizji();
      if (ruch_gracza_1 = 1) then
        punkty_1 := punkty_1 + licznik_punktow;
      licznik_punktow := 0;
        {if lewo = 1 then
          p_p := p_p - PREDKOSC_PALETKI
        else if prawo = 1 then
          p_p := p_p + PREDKOSC_PALETKI;
        pos_pilka^.x := pos_pilka^.x + x_p;
        pos_pilka^.y := pos_pilka^.y + y_p; }
      if (t_magnes_1 = 0) then
        magnes_1 := 0;
      Rysuj_plansze();
      SDL_BlitSurface(paletka, paletka_wsp, ekran, pos_p);
      SDL_BlitSurface(pilka, pilka_wsp, ekran, pos_pilka);
      sdl_flip(ekran);
      ruch^.key.keysym.sym := SDLK_WORLD_0;
      if (liczba_zyc_1=0) then begin
        SDL_BlitSurface(koniec, win_wsk, ekran, pos_win);
        sdl_updaterect(ekran, 0, 0, 1000, 600);
        SDL_delay(5000);
        gra_trwa:=0;
      end
    end;
  end;
  //Petla gry dla 2 graczy
  procedure gra_2graczy();
  begin
    resetowanie();
    Zapelnianie_planszy_2();
    for i := 1 to ILOSC_BONUSOW do
      bonusy[i][1] := 0;
    x_p:=1;
    while (gra_trwa = 1) do
    begin
      sdl_delay(OPOZNIENIE);
      pos_p^.x := p_p;
      pos_p^.w := w_d;
      pos_p_2^.x := p_p_2;
      pos_p_2^.w := w_d_2;
      paletka_wsp^.w := w_d;
      paletka_wsp_2^.w := w_d_2;
      RuchSI();      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if SDL_POLLEVENT(ruch) = 1 then
        Wczytywanie_klawiszy();
      if (wybuchanie[1] = 1) then
      begin
        Dec(wybuchanie[2]);
        //konczy bonus, petla bonusu;
        if (wybuchanie[2] = 0) then
        begin
          wybuchanie[1] := 0;
          sdl_freesurface(pilka);
          pilka := SDL_LoadBMP('Textures\pilka.bmp');
        end;
      end;
      if (przenikanie[1] = 1) then
      begin
        Dec(przenikanie[2]);
        //konczy bonus, petla bonusu;
        if (przenikanie[2] = 0) then
        begin
          przenikanie[1] := 0;
        end;
      end;
      if (p_p >= (800 + predkosc_paletki - w_d)) then
      begin
        lewo := 0;
        prawo := 0;
        p_p := p_p - PREDKOSC_PALETKI;
      end
      else if (p_p - predkosc_paletki <= 0 - predkosc_paletki) then
      begin
        lewo := 0;
        prawo := 0;
        p_p := p_p + PREDKOSC_PALETKI;
      end;
      if (p_p_2 >= (800 + predkosc_paletki_2 - w_d_2)) then
      begin
        lewo_2 := 0;
        prawo_2 := 0;
        p_p_2 := p_p_2 - PREDKOSC_PALETKI_2;
      end
      else if (p_p_2 - predkosc_paletki_2 <= 0 - predkosc_paletki_2) then
      begin
        lewo_2 := 0;
        prawo_2 := 0;
        p_p_2 := p_p_2 + PREDKOSC_PALETKI_2;
      end;
      if ((typ_gry = 4) and (ruch_pilki = 0)) then
      begin
        randomize;
        tmp := random(2) + 1;
        if ((tmp = 2) and (typ_gry = 4)) then
          lewo := 1;
        if (tmp = 2) then
          prawo_2 := 1;
        if (tmp = 1) then
          lewo_2 := 1;
        if ((tmp = 1) and (typ_gry = 4)) then
          prawo := 1;
      end;
      if ((Spacja_SI = 1) and (typ_gry = 3)) then
      begin
        randomize;
        tmp := random(2) + 1;
        Spacja_SI := 0;
        if (tmp = 2) then
          prawo_2 := 1;
        if (tmp = 1) then
          lewo_2 := 1;
      end;
      if ((ruch_pilki = 0) and (lewo = 1) and (ruch_gracza_1 = 1)) then
        //start pileczki w lewo
      begin
        x_p := (-1);
        pos_pilka^.x := pos_pilka^.x - PREDKOSC_PALETKI;
        if (ruch^.key.keysym.sym = SDLK_SPACE) or (typ_Gry = 4) then
        begin
          ruch_pilki := 1;
          y_p := -1;
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_gracza_2 := 0;
          ruch_gracza_1 := 1;
        end;
      end
      else if ((ruch_pilki = 0) and (prawo = 1) and (ruch_gracza_1 = 1)) then
        //start pileczki w prawo
      begin
        x_p := 1;
        pos_pilka^.x := pos_pilka^.x + PREDKOSC_PALETKI;
        if (ruch^.key.keysym.sym = SDLK_SPACE) or (typ_Gry = 4) then
        begin
          ruch_pilki := 1;
          y_p := -1;
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_gracza_2 := 0;
          ruch_gracza_1 := 1;
        end;
        //ruch_pilki := 1;
      end
      else if ((ruch_pilki = 0) and (lewo_2 = 1) and (ruch_gracza_2 = 1)) then
        //start pileczki w lewo
      begin
        x_p := (-1);
        pos_pilka^.x := pos_pilka^.x - PREDKOSC_PALETKI_2;
        if (ruch^.key.keysym.sym = SDLK_SPACE) or (typ_Gry = 3) or (typ_Gry = 4) then
        begin
          ruch_pilki := 1;
          y_p := 1;
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_gracza_1 := 0;
          ruch_gracza_2 := 1;
        end;
      end
      else if ((ruch_pilki = 0) and (prawo_2 = 1) and (ruch_gracza_2 = 1)) then
        //start pileczki w prawo
      begin
        x_p := 1;
        pos_pilka^.x := pos_pilka^.x + PREDKOSC_PALETKI_2;
        if (ruch^.key.keysym.sym = SDLK_SPACE) or (typ_Gry = 3) or (typ_Gry = 4) then
        begin
          ruch_pilki := 1;
          y_p := 1;
          pos_pilka^.y := pos_pilka^.y + y_p;
          ruch_gracza_1 := 0;
          ruch_gracza_2 := 1;
        end;
        //ruch_pilki := 1;
      end;
      if lewo = 1 then
        p_p := p_p - PREDKOSC_PALETKI
      else if prawo = 1 then
        p_p := p_p + PREDKOSC_PALETKI;
      if lewo_2 = 1 then
        p_p_2 := p_p_2 - PREDKOSC_PALETKI_2
      else if prawo_2 = 1 then
        p_p_2 := p_p_2 + PREDKOSC_PALETKI_2;
      if ((ruch_pilki = 0) and (pos_pilka^.x > 400) and (pos_pilka^.y > 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 1;
          ruch_gracza_2 := 0;
          y_p := -1;
          Dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if ((ruch_pilki = 0) and (pos_pilka^.x <= 400) and (pos_pilka^.y > 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 1;
          ruch_gracza_2 := 0;
          y_p := -1;
          Dec(t_magnes_1);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if ((ruch_pilki = 0) and (pos_pilka^.x > 400) and (pos_pilka^.y <= 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 0;
          ruch_gracza_2 := 1;
          y_p := 1;
          Dec(t_magnes_2);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if ((ruch_pilki = 0) and (pos_pilka^.x <= 400) and (pos_pilka^.y <= 300)) then
        if (ruch^.key.keysym.sym = SDLK_SPACE) then
        begin
          ruch_pilki := 1;
          ruch_gracza_1 := 0;
          ruch_gracza_2 := 1;
          y_p := 1;
          Dec(t_magnes_2);
          pos_pilka^.y := pos_pilka^.y + y_p;
        end;
      if (ruch_pilki = 1) then
        pos_pilka^.x := pos_pilka^.x + x_p;
      //przesuwanie pilki, w razie potrzeby wywolac dwa razy z funkcja wykrywanie kolizi (bonus przyspieszania/zwalniania pileczki)
      if (ruch_pilki = 1) then
        pos_pilka^.y := pos_pilka^.y + y_p;
      Wykrywanie_kolizji_2();
      if (ruch_gracza_1 = 1) then
        punkty_1 := punkty_1 + licznik_punktow;
      if (ruch_gracza_2 = 1) then
        punkty_2 := punkty_2 + licznik_punktow;
      if (t_magnes_1 = 0) then
        magnes_1 := 0;
      if (t_magnes_2 = 0) then
        magnes_2 := 0;
      Rysuj_plansze_2();
      //sdl_freesurface(ekran);
      //SDL_FLIP(ekran);
      ruch^.key.keysym.sym := SDLK_WORLD_0;   //czyszczenie bufora klawiszy,
      if (liczba_zyc_1=0) then begin
        SDL_BlitSurface(win_2, win_wsk, ekran, pos_win);
        sdl_updaterect(ekran, 0, 0, 1000, 600);
        SDL_delay(5000);
        gra_trwa:=0;
      end
      else if (liczba_zyc_2=0) then begin
        SDL_BlitSurface(win_1, win_wsk, ekran, pos_win);
        sdl_updaterect(ekran, 0, 0, 1000, 600);
         SDL_delay(5000);
        gra_trwa:=0;
      end;
      sdl_updaterect(ekran, 0, 0, 1000, 600);
    end;
  end;
  //Petla gry obslugujaca wybor gry
  procedure petla_gry();
  begin
    while (gra_trwa = 0) do
    begin
      SDL_BlitSurface(tlo_menu, tlo_menu_wsp, ekran, pos_tlo_menu);
      if (typ_gry = 1) then
      begin
        wybor := SDL_LoadBMP('Textures\1_gracz.bmp');
        pos_wybor^.x := 319;
        pos_wybor^.y := 285;
        SDL_BlitSurface(wybor, wybor_wsp, ekran, pos_wybor);
        SDL_freesurface(wybor);
      end;
      if (typ_gry = 2) then
      begin
        wybor := SDL_LoadBMP('Textures\2_graczy.bmp');
        pos_wybor^.x := 319;
        pos_wybor^.y := 327;
        SDL_BlitSurface(wybor, wybor_wsp, ekran, pos_wybor);
        SDL_freesurface(wybor);
      end;
      if (typ_gry = 3) then
      begin
        wybor := SDL_LoadBMP('Textures\gracz_cpu.bmp');
        pos_wybor^.x := 319;
        pos_wybor^.y := 369;
        SDL_BlitSurface(wybor, wybor_wsp, ekran, pos_wybor);
        SDL_freesurface(wybor);
      end;
      if (typ_gry = 4) then
      begin
        wybor := SDL_LoadBMP('Textures\cpu_cpu.bmp');
        pos_wybor^.x := 319;
        pos_wybor^.y := 411;
        SDL_BlitSurface(wybor, wybor_wsp, ekran, pos_wybor);
        SDL_freesurface(wybor);
      end;
      if (typ_gry = 5) then
      begin
        wybor := SDL_LoadBMP('Textures\exit.bmp');
        pos_wybor^.x := 319;
        pos_wybor^.y := 452;
        SDL_BlitSurface(wybor, wybor_wsp, ekran, pos_wybor);
        SDL_freesurface(wybor);
      end;
      if SDL_POLLEVENT(menu) = 1 then
      begin
        case menu^.type_ of
          SDL_KEYDOWN:
          begin
            if (menu^.key.keysym.sym = SDLK_DOWN) then
            begin
              if typ_gry = 5 then
                typ_gry := 1
              else
                typ_gry := typ_gry + 1;
            end
            else if (menu^.key.keysym.sym = SDLK_UP) then
            begin
              if typ_gry = 1 then
                typ_gry := 5
              else
                typ_gry := typ_gry - 1;
            end
            else if (menu^.key.keysym.sym = SDLK_RETURN) then
              gra_trwa := 1
            else if (menu^.key.keysym.sym = SDLK_ESCAPE) then
              break;
          end;
        end;
      end;
      sdl_flip(ekran);
      if gra_trwa = 1 then
      begin
        if typ_gry = 1 then
          gra_1gracz();
        if typ_gry = 2 then
          gra_2graczy();
        if typ_gry = 3 then
          gra_2graczy();     //TEST - BRAK CPU
        if typ_gry = 4 then
          gra_2graczy();     //TEST - BRAK CPU
        if typ_gry = 5 then
          break;
      end;
    end;
  end;
  //Funkcja Glowna
begin
  typ_gry := 1; //TEST
  gra_trwa := 0;
  ruch_pilki := 0;
  punkty_1 := 0;
  punkty_2 := 0;
  licznik_bonusow := 1;
  ruch_gracza_1 := 1;
  PREDKOSC_PALETKI := 3;
  PREDKOSC_PALETKI_2 := 3;
  w_d := 150; //domyslna dlugosc paletki
  p_p := 350; //domyslna pozycja paletki
  w_d_2 := 150; //domyslna dlugosc paletki 2
  p_p_2 := 350; //domyslna pozycja paletki 2
  Inicjalizacja_SDL();
  Wczytanie_tekstur();
  petla_gry();
  //gra();
  //sdl_delay(25000);      //test
  Wylacz_gre();
end.
