#include <Windows.h>
#include <iostream>

using namespace std; 

HWND GetDeckstopIconsHandle()
{
	HWND progman = FindWindow(L"Progman", NULL);
	if (!progman) return NULL;

	HWND shellView = FindWindowEx(progman, NULL, L"SHELLDLL_DefView", NULL);
	if (!shellView) return NULL;

	HWND listView = FindWindowEx(shellView, NULL, L"SysListView32", NULL);
	return listView;
}

int main()
{
	setlocale(LC_ALL, "RU");

	std::cout << " 1 - показать иконки\n";
	std::cout << " 2 - скрыть иконки иконки\n";
	std::cout << " ESC - выход\n";

	HWND icons = GetDeckstopIconsHandle();
	if (!icons)
	{
		std::cout << "Не удалось найти иконки рабочего стола\n";
		return 1;
	}

	while (true)
	{
		if (GetAsyncKeyState('1') & 1)
		{
			ShowWindow(icons, SW_SHOW);
			std::cout << "Иконки Показаны\n";
		}

		if (GetAsyncKeyState('2') & 1)
		{
			ShowWindow(icons, SW_HIDE);
			std::cout << "Иконки Скрыты" << std::endl;

		}

		if (GetAsyncKeyState(VK_ESCAPE) & 1)
		{
			break;
		}
		Sleep(50);
	}
	return 0;
}
