class Postomat {
    var cells: map<int, bool> // true - комірка зайнята, false - вільна
    var codes: map<int, int> // ID посилки -> код доступа
    var payments: map<int, int> // ID посилки -> сума оплати

    constructor ()
        ensures cells.Keys == {}
        ensures codes.Keys == {}
        ensures payments.Keys == {}
    {
        cells := map[];
        codes := map[];
        payments := map[];
    }

    method AddParcel(parcelId: int, cellId: int, code: int, amount: int) 
        requires (cellId !in cells) || (cells[cellId] == false) // комірка має бути вільною
        requires (parcelId !in codes) // ID посилки має бути новим
        ensures (cellId in cells) && (cells[cellId] == true)
        ensures (parcelId in codes)
        ensures (parcelId in payments)
        modifies this
    {
        cells := cells[cellId := true];
        codes := codes[parcelId := code];
        payments := payments[parcelId := amount];
        print "Посилка ", parcelId, " прийнята в комірку ", cellId, "\n";
    }

    method PayForParcel(parcelId: int, balance: int) returns (paid: bool)
        requires parcelId in payments // Посилка має бути в системі
        modifies this`payments
        ensures parcelId in payments
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

    method RetrieveParcel(parcelId: int, cellId: int, code: int, paid: bool) returns (result: bool) 
        requires cellId in cells && cells[cellId] == true // Комірка зайнята
        requires parcelId in codes // Посилка має бути в системі
        modifies this`cells
        ensures (result == true) || (cellId in cells && cells[cellId] == true)
    {
        if (codes[parcelId] != code) {
            print "Неправильний код для посилки ", parcelId, "\n";
            return false;
        } else {
            if (paid) {
                cells := cells[cellId := false];
                print "Посилка ", parcelId, " видана\n";
                return true;
            } else {
                print "Оплата не проведена, видача неможлива\n";
                return false;
            }
        }
    }
}

method Main() {
    var locker := new Postomat();

    locker.AddParcel(101, 1, 1111, 50); // Прийняти посилку

    var success := locker.PayForParcel(101, 49); // Неуспішна оплата
    var retrieved := locker.RetrieveParcel(101, 1, 1111, success);
    if !retrieved {
        success := locker.PayForParcel(101, 50); // Успішна оплата
        
        var retrieved2 := locker.RetrieveParcel(101, 1, 1110, success); // Неправильний код

        if !retrieved2 {
            var retrieved3 := locker.RetrieveParcel(101, 1, 1111, success); // Правильний код
            if !retrieved3 {
                print("unexpected retrieved3");
            } else {
                print("OK!");
            }
        } else {
            print("unexpected retrieved2");
        }
    } else {
        print("unexpected retrieved");
    }
}
