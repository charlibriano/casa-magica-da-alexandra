@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ====== CONFIG ======
set "SOURCE=C:\Users\Palhares\Desktop\Felipe"
set "REMOTE=https://github.com/charlibriano/casa-magica-da-alexandra.git"
set "LOG=%USERPROFILE%\Desktop\upload_github_debug.log"

echo [INIT] %DATE% %TIME% > "%LOG%"

REM ====== CHECAGENS ======
where git >> "%LOG%" 2>&1
if errorlevel 1 (
  echo ERRO: Git nao encontrado. Instale: https://git-scm.com/download/win
  echo ERRO: Git nao encontrado. >> "%LOG%"
  pause
  exit /b 1
)

if not exist "%SOURCE%" (
  echo ERRO: Pasta nao encontrada: "%SOURCE%"
  echo ERRO: SOURCE inexistente. >> "%LOG%"
  pause
  exit /b 1
)

cd /d "%SOURCE%" || (
  echo ERRO: Nao foi possivel entrar em "%SOURCE%"
  echo ERRO: cd falhou. >> "%LOG%"
  pause
  exit /b 1
)

REM ====== INFO NA TELA ======
echo ====================================================
echo  Upload para GitHub
echo  Origem: %SOURCE%
echo  Destino: %REMOTE%
echo  Log: %LOG%
echo ====================================================

REM ====== AVISO SOBRE ARQUIVOS MUITO GRANDES (podem travar push) ======
echo [INFO] Verificando arquivos > 90MB... | tee
for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "Get-ChildItem -Recurse -File | Where-Object { $_.Length -gt 90MB } | ForEach-Object { $_.FullName }"`) do (
  echo [ALERTA] Arquivo grande: %%F
  echo [ALERTA] Arquivo grande: %%F >> "%LOG%"
)
REM (Se listar algo acima, considere remover/compactar ou usar Git LFS)

REM ====== CONFIG DE IDENTIDADE (evita erro 'please tell me who you are') ======
for /f "tokens=* usebackq" %%A in (`git config user.email`) do set GITEMAIL=%%A
if "%GITEMAIL%"=="" (
  git config user.email "contato@exemplo.com" >> "%LOG%" 2>&1
)
for /f "tokens=* usebackq" %%A in (`git config user.name`) do set GITNAME=%%A
if "%GITNAME%"=="" (
  git config user.name "Felipe" >> "%LOG%" 2>&1
)

REM ====== GIT INIT/ADD/COMMIT ======
git init >> "%LOG%" 2>&1
git add -A >> "%LOG%" 2>&1

REM se nao houver nada pra commitar, cria um arquivo marcador
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "upload inicial de arquivos" >> "%LOG%" 2>&1
) else (
  echo [INFO] Nada novo para commitar; criando marcador... >> "%LOG%"
  echo Upload em %DATE% %TIME% > __upload_marker__.txt
  git add __upload_marker__.txt >> "%LOG%" 2>&1
  git commit -m "marker: upload vazio" >> "%LOG%" 2>&1
)

git branch -M main >> "%LOG%" 2>&1

REM ====== REMOTE ======
git remote remove origin >> "%LOG%" 2>&1
git remote add origin "%REMOTE%" >> "%LOG%" 2>&1

REM ====== PUSH ======
echo [INFO] Enviando para o GitHub (main)...
git -c credential.helper=manager-core -c http.sslVerify=true ^
    -c http.postBuffer=524288000 ^
    push -u origin main >> "%LOG%" 2>&1

if errorlevel 1 (
  echo.
  echo ERRO no push. Veja as ultimas linhas do log:
  echo --------------------------------------------
  powershell -NoProfile -Command "Get-Content -Tail 30 -Path '%LOG%'"
  echo --------------------------------------------
  echo Possiveis causas: token ausente/sem escopo repo, 2FA, proxy, arquivo >100MB, conflito no remote.
  pause
  exit /b 1
)

echo.
echo =================== SUCESSO ====================
echo  Repositorio: %REMOTE%
echo  Log: %LOG%
echo ================================================
echo.
pause
endlocal
exit /b 0
