# QMobileAPI

Network layer to communicate with 4D server rest API

## Initialize
Create your endpoint to make request

```swift
let url = URL(string: "http://your4dserverURL")!
let api = APIManager(url: url)
```

## Make request

### Server info
```swift
api.loadStatus { result in
   switch result {
      case .success(let info):
        print("\(status.ok)")
      case .failure(let error):
        print("\(error)")
   }
}
api.loadInfo { result in
  switch result {
     case .success(let info):
       ...
     case .failure(let error):
       print("\(error)")
  }
}
```

### Table/Catalog

```swift
api.loadTables { result in
  switch result {
     case .success(let tables):
      for table in tables {
       ...
      }
     case .failure(let error):
       print("\(error)")
  }
}
api.loadTable(name: "ATable") { result in
  switch result {
     case .success(let table):
       ...
     case .failure(let error):
       print("\(error)")
  }
}
api.loadCatalog { result in
  switch result {
     case .success(let catalogs):
       for catalog in catalogs {
        ...
       }
     case .failure(let error):
       print("\(error)")
  }
}
```

### Records
