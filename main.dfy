class Postomat {
    var cells: map<int, bool> // true - комірка зайнята, false - вільна
    var codes: map<int, int> // ID посилки -> код доступа
    var payments: map<int, int> // ID посилки -> сума оплати

    constructor () {
        cells := map[];
        codes := map[];
        payments := map[];
    }

    method AddParcel(parcelId: int, cellId: int, code: int, amount: int) 
        requires (cellId !in cells) || (cells[cellId] == false) // комірка має бути вільною
        requires (parcelId !in codes) // ID посилки має бути новим
        modifies this
    {
        cells := cells[cellId := true];
        codes := codes[parcelId := code];
        payments := payments[parcelId := amount];
        print "Посилка ", parcelId, " прийнята в комірку ", cellId, "\n";
    }

    method PayForParcel(parcelId: int, balance: int) returns (paid: bool)
        requires parcelId in payments // Посилка має бути в системі
        modifies this
    {
        if (payments[parcelId] == 0) {
            print "Оплата вже була проведена";
            return true;
        }

        if (payments[parcelId] <= balance) {
            payments := payments[parcelId := 0];
            print "Оплата успішна\n";
            return true;
        } else {
            print "Недостатньо коштів\n";
            return false;
        }
    }

    method RetrieveParcel(parcelId: int, cellId: int, code: int, paid: bool) 
        requires cellId in cells && cells[cellId] == true // Комірка зайнята
        requires parcelId in codes // Посилка має бути в системі
        modifies this
    {
        if (codes[parcelId] != code) {
            print "Неправильний код для посилки ", parcelId, "\n";
        } else {
            if (paid) {
                cells := cells[cellId := false];
                print "Посилка ", parcelId, " видана\n";
            } else {
                print "Оплата не проведена, видача неможлива\n";
            }
        }
    }
}

method Main() {
    var locker := new Postomat();
    
    locker.AddParcel(101, 1, 1111, 50); // Прийняти посилку

    var success := locker.PayForParcel(101, 49); // Неуспішна оплата
    locker.RetrieveParcel(101, 1, 1111, success);

    success := locker.PayForParcel(101, 50); // Успішна оплата
    
    locker.RetrieveParcel(101, 1, 1110, success); // Неправильний код
    locker.RetrieveParcel(101, 1, 1111, success); // Правильний код
}
