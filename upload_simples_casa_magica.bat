@echo off
setlocal

rem >>> AJUSTE SE PRECISAR:
set "SOURCE=C:\Users\Palhares\Desktop\Felipe"
set "REMOTE=https://github.com/charlibriano/casa-magica-da-alexandra.git"

where git >nul 2>nul || (
  echo ERRO: Git nao encontrado. Instale em https://git-scm.com/download/win
  pause
  exit /b 1
)

if not exist "%SOURCE%" (
  echo ERRO: Pasta nao encontrada: %SOURCE%
  pause
  exit /b 1
)

cd /d "%SOURCE%"

echo ==== SUBINDO PARA: %REMOTE% ====

git init
git add -A
git commit -m "upload inicial" 2>nul
git branch -M main

rem zera origin (se existir) e aponta para o repo certo
git remote remove origin 2>nul
git remote add origin "%REMOTE%"

rem tenta push direto
git push -u origin main && goto :OK

rem se o push foi rejeitado (repo nao vazio), faz pull --rebase e tenta de novo
echo Push rejeitado. Tentando sincronizar com o remoto...
git pull --rebase origin main
git push -u origin main && goto :OK

echo.
echo ERRO no push. Verifique credenciais (token/2FA) ou se ha arquivos >100MB.
pause
exit /b 1

:OK
echo.
echo ✅ Upload concluido: %REMOTE%
echo.
pause
exit /b 0
