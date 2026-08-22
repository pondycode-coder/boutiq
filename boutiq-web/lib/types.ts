export type UserRole = "admin" | "salesperson";

export interface AppUser {
  id: string;
  name: string;
  role: UserRole;
}

export interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  description: string | null;
  image_url: string | null;
  stock_quantity: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export type OrderStatus =
  | "paid"
  | "pending"
  | "partial"
  | "cancelled"
  | "preparing"
  | "ready"
  | "delivered";

export interface OrderRow {
  id: string;
  store_id: string;
  vendor_id: string;
  status: string;
  payment_method: string;
  payment_status: string;
  subtotal: number;
  vat_amount: number;
  total_amount: number;
  notes: string | null;
  client_id: string | null;
  salesperson_id: string | null;
  cash_payment_id: string | null;
  confirmed_at: string | null;
  created_at: string;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  vendor_id: string;
  quantity: number;
  unit_price: number;
  vat_rate: number;
  line_subtotal: number;
  line_vat_amount: number;
  line_total: number;
}

export interface Client {
  id: string;
  name: string;
  name_fr: string;
  client_type: string;
  region: string;
  division: string;
  subdivision: string;
  address: string;
  phone: string;
  email: string | null;
  contact_person: string;
  credit_limit: number;
  current_balance: number;
  payment_terms_days: number;
  preferred_payment_method: string;
  assigned_route_id: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface CashPayment {
  id: string;
  order_id: string;
  store_id: string;
  client_id: string | null;
  salesperson_id: string | null;
  amount_tendered: number;
  change_amount: number;
  paid_at: string;
  notes: string | null;
}
