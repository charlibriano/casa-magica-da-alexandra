@echo off
setlocal EnableExtensions

rem ============= CONFIGURACAO =============
set "SOURCE=C:\Users\Palhares\Desktop\Felipe"
set "REMOTE=https://github.com/charlibriano/casa-magica-da-alexandra.git"
set "GIT_NAME=Felipe"
set "GIT_EMAIL=charlibriano@users.noreply.github.com"
rem ========================================

where git >nul 2>nul || (
  echo ERRO: Git nao encontrado. Instale: https://git-scm.com/download/win
  pause & exit /b 1
)

if not exist "%SOURCE%" (
  echo ERRO: Pasta nao encontrada: %SOURCE%
  pause & exit /b 1
)

cd /d "%SOURCE%" || (echo ERRO: nao foi possivel entrar em %SOURCE% & pause & exit /b 1)

echo ================= SUBINDO PARA =================
echo  Origem: %SOURCE%
echo  Remoto: %REMOTE%
echo =================================================
echo.

rem --- inicia repo (ou reaproveita o existente) ---
git init

rem --- configura identidade local (evita "tell me who you are") ---
git config user.name  "%GIT_NAME%"
git config user.email "%GIT_EMAIL%"

rem --- adiciona tudo ---
git add -A

rem --- se nao houver nada staged, cria um marcador para garantir commit ---
for /f "tokens=1" %%Z in ('git diff --cached --name-only') do set HAVE_STAGED=1
if not defined HAVE_STAGED (
  echo upload marker > __upload_marker__.txt
  git add __upload_marker__.txt
)

rem --- faz commit (se falhar, mostra erro) ---
git commit -m "upload inicial de arquivos" || (
  echo ERRO ao fazer commit. Verifique se ha arquivos bloqueados/sem permissao.
  pause & exit /b 1
)

rem --- garante branch main ---
git branch -M main

rem --- configura remoto ---
git remote remove origin 2>nul
git remote add origin "%REMOTE%"

rem --- tenta push direto ---
echo Fazendo push para main...
git push -u origin main && goto :OK

rem --- se o push foi rejeitado (repo ja tem commits), sincroniza e tenta de novo ---
echo Push rejeitado. Tentando sincronizar com o remoto...
git fetch origin
git pull --rebase origin main || (
  echo Falha no pull --rebase. Tentando mesclar...
  git pull origin main
)

echo Tentando push novamente...
git push -u origin main || (
  echo.
  echo ERRO no push. Possiveis causas:
  echo  - Credenciais (token) nao fornecidas ou sem escopo repo
  echo  - 2FA exigindo confirmacao no navegador
  echo  - Arquivos > 100MB (GitHub recusa) — remova ou use Git LFS
  echo  - Conflitos com conteudo ja existente no remoto
  echo.
  pause & exit /b 1
)

:OK
echo.
echo ✅ Upload concluido com sucesso!
echo Repo: %REMOTE%
echo.
pause
exit /b 0
