if file.open("init.lua", "r") then
    while(true) do
      print(file.readline())
    end
    file.close()
end
