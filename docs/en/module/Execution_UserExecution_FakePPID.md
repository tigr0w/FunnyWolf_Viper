# Parent process PID disguise evasion detection

# Main functions

The module generates an exe file with payload, and automatically migrates it to the ie process after execution, and disguises the parent process (PPID) as explorer.exe (explore
manager)

# How to operate

+ Open the module, select Listen, run
+ Generate cpp source code and download source code

![1618196370427-49453352-f021-4e57-85ce-961887848cdf.webp](./img/h92jdFYwBd8Er83Q/1618196370427-49453352-f021-4e57-85ce-961887848cdf-805946.webp)

+ Download the source code and use Visual Studio to compile the source code

> Viper's built-in compiler is Mingw64. The effect of free killing is poor when compiling this module, so the source code user can compile it by themselves.
>

![1623216997711-f2941d0e-18e7-487c-bb9a-65be6d51cb27.webp](./img/h92jdFYwBd8Er83Q/1623216997711-f2941d0e-18e7-487c-bb9a-65be6d51cb27-588689.webp)

![1618196613831-3938b709-0ff3-468c-a325-db896adedf6f.webp](./img/h92jdFYwBd8Er83Q/1618196613831-3938b709-0ff3-468c-a325-db896adedf6f-587032.webp)

![1618196988646-0937a913-a702-4dfd-b5ed-65299315eeca.webp](./img/h92jdFYwBd8Er83Q/1618196988646-0937a913-a702-4dfd-b5ed-65299315eeca-697048.webp)

+ Upload to the target host and run


+ Effect when the exe generated by this module is online using webshell

![1618196850846-8ba148ed-c65e-49e8-86d1-283873bd581e.webp](./img/h92jdFYwBd8Er83Q/1618196850846-8ba148ed-c65e-49e8-86d1-283873bd581e-563263.webp)

![1618197349360-c296aa54-81f8-4df3-8f37-11de0426b8ad.webp](./img/h92jdFYwBd8Er83Q/1618197349360-c296aa54-81f8-4df3-8f37-11de0426b8ad-998005.webp)

![1618197373498-d9e78731-2635-4f2f-8a38-3b501569d15b.webp](./img/h92jdFYwBd8Er83Q/1618197373498-d9e78731-2635-4f2f-8a38-3b501569d15b-651629.webp)

You can see that the payload process is ie and the parent process is iexplore.exe. You can have limited defense AV detection and blue team traceability.

+ Comparative test, when using webshell to run the exe generated by other unkilled modules online

![1618197522696-945cf91a-40cc-4267-a210-e310d04cac73.webp](./img/h92jdFYwBd8Er83Q/1618197522696-945cf91a-40cc-4267-a210-e310d04cac73-735692.webp)![1618197555750-26cb9144-39f3-41c6-b52d-85eb3470ec6f.webp](./img/h92jdFYwBd8Er83Q/1618197555750-26cb9144-39f3-41c6-b52d-85eb3470ec6f-698744.webp)

You can see that the parent process of payload is cmd.exe (ice scorpion)






