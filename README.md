# Small-Medium-Business-Patching-Scripts

Description:
------------
Many big businesses buy expensive tools to automate their Windows patching or security updates. System Center Configuration Manager (SCCM) is a software management suite provided by Microsoft that allows IT teams to manage Windows-based computers. SCCM of different vendors are the most populator product. This tool is good for businesses with over 30 or more Windows running in the environment with million dollar budget. However, there are small and medium businesses ("Mom-and-pop" is a colloquial term used to describe a small, family-owned, or independent business) that could  not afford the tool. This issue could be resolved by developing powershell scripts to locally and remotely patch Windows systems.

Purpose:
--------
Powershell has the available modules and/or API(s) to update patches - security patch or any other kind of patches to be applied on any Microsoft products. It would be demonstrated here. It is important to code less as much as possible in order to make everything simple (Refactoring). The less code to accomplish the task, the easier to maintain.

Requirements/Knowledge:
------------
1. Powershell
2. Windows Architecture (environment) and Administration
3. Basic Network Knowledge (Configurations)
4. MS Scheduling System
5. Administrative Privilege
6. Configure localhost network: c:\windows\system32\drivers\etc\hosts to make an entry of your IP(s) to be patched.


Pre-requisites: Set the following before running (Local/Remote Machine)
------------------------------------------------
1.  Set-ExecutionPolicy RemoteSigned
2.  Must have administrative rights on the remote machine being patched (local admin)
3.  For security, you don't want the user to patch their systems for security reasons. Disable the users' ability to change their systems. This is called security control. Users must have only "Standard" user privilege to prevent them from making any changes to their systems.
4. Configure MS Defender Firewall to allow certain applications
5. Allow the local machine to accept remote connection
6. Execute: "winrm quickconfig" to enable remote request

Running:
--------
./win_updates.ps1

Note that you can set this one up to run in scheduler mode.

Future Work:
------------
This program could be expanded to monitor and tailor the patches to specific system. Currently, it would patch the systems found in the Microsoft server; it does not do any filtering which patches to apply. It is important to descriminate which patches are needed as not to break the the applications running in the system. There are patches that many break the applications current program. In addition, all the running taskings should be logged appropriately with email or any messaging system to the administrators.
