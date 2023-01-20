export interface Bootstrap {
  current_user: {
    email: string
    id: number
  }
}

export interface Item {
  id: number
  name: string
  needed: number
  newlyAdded: boolean
}

export interface Store {
  id: number
  name: string
  own_store: boolean
  private: boolean
}
