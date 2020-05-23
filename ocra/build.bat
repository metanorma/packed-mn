@echo off
cls

echo [building metanorma windows executable with ocra]
echo -------------------------------------------------
echo.

echo [installing ocra]
echo.
:: > NUL
call gem install ocra
echo.

echo [building executable]
echo.
call ocra --gem-full --add-all-core --gemfile Gemfile metanorma.rb
echo.

echo [done]