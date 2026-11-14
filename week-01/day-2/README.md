# Week 01 · Day 2

## چرا متغیرها را داخل Double Quote می‌گذاریم؟

در اسکریپت‌ها همیشه نوشته‌ام `"$target"` و `"$LOG"` و نه `$target` و `$LOG`.

دلیلش این است که Bash مقدار یک متغیر بدون کوتیشن را در فاصله‌ها (Space) می‌شکند و
چند کلمه‌ی جدا می‌سازد (Word Splitting). اگر اسم پوشه یا فایل فاصله داشته باشد
(مثل `server logs`) اتفاق بد می‌افتد:

    LOG="server logs/app.log"
    grep -c ERROR $LOG      # Bash می‌بیند: grep -c ERROR server logs/app.log  -> دو فایل جدا!
    grep -c ERROR "$LOG"    # Bash می‌بیند: یک آرگومان کامل -> درست کار می‌کند

نتیجه‌ی بی‌کوتیشن: خطای `No such file or directory` و گزارش اشتباه.
پس قاعده این است: **هر Variable را داخل Double Quote بگذار**، مگر دلیل خاصی داشته باشی.

## محتوای این پوشه

- `server.log` : لاگ نمونه (۲۲ خط)
- `analyze.sh` : تحلیل لاگ (کل خط‌ها، تعداد هر سطح، ERROR ها با شماره‌ی خط، problems.txt، کاربر برتر)
- `toolbox/` : نسخه‌ی mkday و خطوط اضافه‌شده به ~/.bashrc
