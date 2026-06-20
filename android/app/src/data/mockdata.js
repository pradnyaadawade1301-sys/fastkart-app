// src/data/mockData.js

export const STATS = [
  { icon: '💰', label: 'Total Revenue',  value: '₹12.4L', change: '+22%', up: true,  iconBg: '#FFF0EB', color: '#FF6B35' },
  { icon: '🛍️', label: 'Total Orders',   value: '8,291',  change: '+15%', up: true,  iconBg: '#ECFDF5', color: '#10B981' },
  { icon: '👥', label: 'Users',          value: '28.4K',  change: '+9%',  up: true,  iconBg: '#EFF6FF', color: '#3B82F6' },
  { icon: '⚡', label: 'Active Features', value: '15',     change: 'All Live', up: true, iconBg: '#F5F3FF', color: '#8B5CF6' },
];

export const FEATURE_REVENUE = [
  { name: 'Food',     value: 560000, color: '#FF6B35', height: '90%'  },
  { name: 'Grocery',  value: 280000, color: '#10B981', height: '45%'  },
  { name: 'Movies',   value: 140000, color: '#3B82F6', height: '35%'  },
  { name: 'Hotels',   value: 98000,  color: '#8B5CF6', height: '28%'  },
  { name: 'Rides',    value: 76000,  color: '#F59E0B', height: '22%'  },
  { name: 'Medicine', value: 58000,  color: '#EF4444', height: '18%'  },
  { name: 'Bikes',    value: 42000,  color: '#EC4899', height: '14%'  },
  { name: 'Travel',   value: 38000,  color: '#06B6D4', height: '12%'  },
  { name: 'Trains',   value: 31000,  color: '#84CC16', height: '10%'  },
  { name: 'Leisure',  value: 24000,  color: '#F97316', height: '8%'   },
];

export const FEATURES = [
  { id: 'orders',       icon: '🍕', name: 'Food Delivery', count: '3,847 orders',    status: 'live',    route: '/orders'    },
  { id: 'grocery',      icon: '🛒', name: 'Grocery',       count: '1,240 orders',    status: 'live',    route: '/grocery'   },
  { id: 'movies',       icon: '🎬', name: 'Movies',        count: '892 bookings',    status: 'live',    route: '/movies'    },
  { id: 'hotels',       icon: '🏨', name: 'Hotels',        count: '431 bookings',    status: 'live',    route: '/hotels'    },
  { id: 'rides',        icon: '🚕', name: 'Rides & Cabs',  count: '678 rides',       status: 'partial', route: '/rides'     },
  { id: 'bikes',        icon: '🚲', name: 'Bike Rentals',  count: '312 rentals',     status: 'live',    route: '/bikes'     },
  { id: 'travel',       icon: '✈️', name: 'Flights',       count: '198 bookings',    status: 'partial', route: '/travel'    },
  { id: 'trains',       icon: '🚂', name: 'Train Tickets', count: '542 tickets',     status: 'live',    route: '/trains'    },
  { id: 'medicine',     icon: '💊', name: 'Medicine',      count: '287 orders',      status: 'live',    route: '/medicine'  },
  { id: 'leisure',      icon: '🎭', name: 'Leisure/Events',count: '156 bookings',    status: 'live',    route: '/leisure'   },
];

export const FEATURE_STATUS = [
  { name: '🍕 Food Delivery', status: 'live'    },
  { name: '🛒 Grocery',       status: 'live'    },
  { name: '🎬 Movies',        status: 'live'    },
  { name: '🏨 Hotels',        status: 'live'    },
  { name: '🚕 Rides',         status: 'partial' },
  { name: '🚲 Bikes',         status: 'live'    },
  { name: '✈️ Flights',       status: 'partial' },
  { name: '🚂 Trains',        status: 'live'    },
  { name: '💊 Medicine',      status: 'live'    },
  { name: '🎭 Leisure',       status: 'live'    },
];

export const ACTIVITY = [
  { icon: '🛍️', bg: '#EFF6FF', text: 'New food order #ORD-8821 — Priya Sharma',     time: '2m ago'  },
  { icon: '🎬', bg: '#F5F3FF', text: 'Movie booking — Kalki 2898-AD IMAX',           time: '5m ago'  },
  { icon: '🛒', bg: '#ECFDF5', text: 'Grocery order delivered — Anjali Singh',        time: '8m ago'  },
  { icon: '🚕', bg: '#FFFBEB', text: 'Cab ride started — Mumbai → Airport',           time: '11m ago' },
  { icon: '🏨', bg: '#FEF2F2', text: 'Hotel booking — Taj Lands End, 3 nights',      time: '18m ago' },
  { icon: '💊', bg: '#ECFDF5', text: 'Medicine order confirmed — Apollo Pharmacy',    time: '24m ago' },
];

export const FOOD_ORDERS = [
  { id: 'ORD-8821', customer: 'Priya Sharma',  restaurant: 'Biryani Blues',  amount: '₹842',   status: 'delivered',        payment: 'UPI',    time: '2m ago',  items: 3 },
  { id: 'ORD-8820', customer: 'Rahul Gupta',   restaurant: 'Punjabi Tadka',  amount: '₹1,240', status: 'preparing',        payment: 'Card',   time: '8m ago',  items: 5 },
  { id: 'ORD-8819', customer: 'Anjali Singh',  restaurant: 'South Spice',    amount: '₹460',   status: 'out_for_delivery', payment: 'Wallet', time: '14m ago', items: 2 },
  { id: 'ORD-8818', customer: 'Vikram Nair',   restaurant: 'Pizza Palace',   amount: '₹980',   status: 'placed',           payment: 'COD',    time: '19m ago', items: 4 },
  { id: 'ORD-8817', customer: 'Meera Pillai',  restaurant: 'Burger Barn',    amount: '₹350',   status: 'cancelled',        payment: 'UPI',    time: '32m ago', items: 1 },
  { id: 'ORD-8816', customer: 'Amit Verma',    restaurant: 'Dosa Corner',    amount: '₹220',   status: 'delivered',        payment: 'Card',   time: '45m ago', items: 2 },
  { id: 'ORD-8815', customer: 'Sunita Rao',    restaurant: 'Rolls & Wraps',  amount: '₹680',   status: 'delivered',        payment: 'UPI',    time: '1h ago',  items: 3 },
  { id: 'ORD-8814', customer: 'Karan Mehta',   restaurant: 'Biryani Blues',  amount: '₹1,100', status: 'preparing',        payment: 'Card',   time: '1h ago',  items: 4 },
];

export const GROCERY_ORDERS = [
  { id: 'GRO-2241', customer: 'Priya Sharma', items: '12 items', amount: '₹1,840', slot: '10am-12pm', status: 'delivered' },
  { id: 'GRO-2240', customer: 'Rahul Gupta',  items: '5 items',  amount: '₹640',   slot: '2pm-4pm',   status: 'packing'   },
  { id: 'GRO-2239', customer: 'Anjali Singh', items: '8 items',  amount: '₹2,100', slot: '6pm-8pm',   status: 'on_way'    },
  { id: 'GRO-2238', customer: 'Vikram Nair',  items: '3 items',  amount: '₹380',   slot: '8pm-10pm',  status: 'placed'    },
];

export const MOVIE_BOOKINGS = [
  { id: 'MOV-441', customer: 'Vikram Nair',  movie: 'Kalki 2898-AD', cinema: 'PVR Phoenix',   seats: 2, amount: '₹780',   date: 'Today 7pm',    status: 'confirmed' },
  { id: 'MOV-440', customer: 'Meera Pillai', movie: 'Pushpa 2',      cinema: 'INOX R-City',   seats: 4, amount: '₹1,560', date: 'Today 9pm',    status: 'confirmed' },
  { id: 'MOV-439', customer: 'Sunita Rao',   movie: 'Avengers',      cinema: 'Cinepolis',     seats: 1, amount: '₹420',   date: 'Tomorrow 3pm', status: 'pending'   },
  { id: 'MOV-438', customer: 'Karan Mehta',  movie: 'Animal',        cinema: 'PVR Icon',      seats: 3, amount: '₹1,170', date: 'Tomorrow 6pm', status: 'cancelled' },
];

export const HOTEL_BOOKINGS = [
  { id: 'HTL-881', guest: 'Amit Mehta',   hotel: 'Taj Lands End',   city: 'Mumbai',    nights: 3, amount: '₹24,000', checkIn: 'Jun 22', status: 'confirmed' },
  { id: 'HTL-880', guest: 'Riya Kapoor',  hotel: 'Leela Palace',    city: 'Delhi',     nights: 2, amount: '₹18,400', checkIn: 'Jun 25', status: 'pending'   },
  { id: 'HTL-879', guest: 'Suresh Patil', hotel: 'ITC Grand',       city: 'Bangalore', nights: 1, amount: '₹7,200',  checkIn: 'Jun 21', status: 'cancelled' },
  { id: 'HTL-878', guest: 'Priya Rao',    hotel: 'Marriott Mumbai', city: 'Mumbai',    nights: 4, amount: '₹32,000', checkIn: 'Jun 28', status: 'confirmed' },
];

export const RIDE_BOOKINGS = [
  { id: 'RID-1121', customer: 'Priya S.',  driver: 'Ramesh Kumar', route: 'Andheri → BKC',       fare: '₹180', type: 'Mini',  status: 'on_way'    },
  { id: 'RID-1120', customer: 'Rahul G.',  driver: 'Suresh Mishra', route: 'CP → Airport',        fare: '₹420', type: 'Prime', status: 'completed' },
  { id: 'RID-1119', customer: 'Vikram N.', driver: 'Searching...',  route: 'Koramangala → MG Rd', fare: '₹145', type: 'Auto',  status: 'searching' },
  { id: 'RID-1118', customer: 'Anjali S.', driver: 'Javed Patel',   route: 'Juhu → Powai',        fare: '₹240', type: 'Mini',  status: 'completed' },
];

export const BIKE_RENTALS = [
  { id: 'BIK-441', customer: 'Anjali S.', bike: 'Hero Splendor', duration: '4 hrs', amount: '₹240', zone: 'Mumbai North', status: 'returned'  },
  { id: 'BIK-440', customer: 'Karan M.',  bike: 'Royal Enfield', duration: '8 hrs', amount: '₹640', zone: 'Pune West',    status: 'active'    },
  { id: 'BIK-439', customer: 'Deepa N.',  bike: 'Activa 6G',     duration: '2 hrs', amount: '₹120', zone: 'Blr Central',  status: 'overdue'   },
  { id: 'BIK-438', customer: 'Rohit K.',  bike: 'Bullet 350',    duration: '6 hrs', amount: '₹480', zone: 'Delhi South',  status: 'active'    },
];

export const FLIGHT_BOOKINGS = [
  { id: 'FLT-8821', passenger: 'Prashant M.', route: 'BOM → DEL', airline: 'IndiGo',   seats: 2, amount: '₹8,400',  date: 'Jun 25', status: 'confirmed' },
  { id: 'FLT-8820', passenger: 'Sanya R.',    route: 'DEL → BLR', airline: 'Air India', seats: 1, amount: '₹6,200',  date: 'Jun 28', status: 'pending'   },
  { id: 'FLT-8819', passenger: 'Varun T.',    route: 'BLR → HYD', airline: 'SpiceJet',  seats: 3, amount: '₹4,500',  date: 'Jul 2',  status: 'confirmed' },
];

export const TRAIN_BOOKINGS = [
  { id: 'TRN-2241', passenger: 'Amit V.',   train: 'Rajdhani Exp', route: 'NDLS → BCT', cls: '2A', amount: '₹1,840', status: 'confirmed' },
  { id: 'TRN-2240', passenger: 'Shruti P.', train: 'Shatabdi',     route: 'BLR → MAS',  cls: 'CC', amount: '₹890',   status: 'waitlist'  },
  { id: 'TRN-2239', passenger: 'Rajan M.',  train: 'Duronto',      route: 'BCT → NDLS', cls: '3A', amount: '₹1,240', status: 'confirmed' },
];

export const MEDICINE_ORDERS = [
  { id: 'MED-881', customer: 'Mohan K.', pharmacy: 'Apollo Pharmacy', items: 3, prescription: 'uploaded', amount: '₹840',  status: 'delivered' },
  { id: 'MED-880', customer: 'Lata P.',  pharmacy: 'MedPlus',         items: 7, prescription: 'required', amount: '₹2,200', status: 'pending_rx'},
  { id: 'MED-879', customer: 'Rohit S.', pharmacy: 'Netmeds',         items: 2, prescription: 'otc',       amount: '₹320',  status: 'on_way'    },
  { id: 'MED-878', customer: 'Seema J.', pharmacy: 'PharmEasy',       items: 5, prescription: 'uploaded', amount: '₹1,100', status: 'packing'   },
];

export const LEISURE_BOOKINGS = [
  { id: 'LEI-441', customer: 'Nidhi K.',  event: 'Sunburn Festival', tickets: 2, amount: '₹4,800', date: 'Jun 28, 2026', status: 'confirmed' },
  { id: 'LEI-440', customer: 'Akash R.',  event: 'Comedy Night',     tickets: 4, amount: '₹2,400', date: 'Jul 2, 2026',  status: 'pending'   },
  { id: 'LEI-439', customer: 'Pooja M.',  event: 'Yoga Retreat',     tickets: 1, amount: '₹3,500', date: 'Jul 5, 2026',  status: 'confirmed' },
  { id: 'LEI-438', customer: 'Dev S.',    event: 'IPL Match',        tickets: 3, amount: '₹6,000', date: 'Jul 8, 2026',  status: 'confirmed' },
];

export const RESTAURANTS = [
  { id: 'R001', name: 'Biryani Blues',  category: 'Biryani',      rating: 4.7, orders: 284, revenue: '₹1.4L', status: 'active',   city: 'Mumbai',    owner: 'Salim Khan'   },
  { id: 'R002', name: 'Punjabi Tadka',  category: 'North Indian', rating: 4.5, orders: 221, revenue: '₹98K',  status: 'active',   city: 'Delhi',     owner: 'Gurpreet S.'  },
  { id: 'R003', name: 'South Spice',    category: 'South Indian', rating: 4.6, orders: 198, revenue: '₹76K',  status: 'active',   city: 'Bangalore', owner: 'Ramesh Iyer'  },
  { id: 'R004', name: 'Pizza Palace',   category: 'Italian',      rating: 4.3, orders: 176, revenue: '₹88K',  status: 'active',   city: 'Mumbai',    owner: 'Tony D\'Silva' },
  { id: 'R005', name: 'Burger Barn',    category: 'Fast Food',    rating: 4.2, orders: 154, revenue: '₹61K',  status: 'inactive', city: 'Pune',      owner: 'Amit Joshi'   },
  { id: 'R006', name: 'Dosa Corner',    category: 'South Indian', rating: 4.8, orders: 312, revenue: '₹1.2L', status: 'active',   city: 'Chennai',   owner: 'Krishnan V.'  },
];

export const USERS = [
  { id: 'U001', name: 'Priya Sharma',  phone: '+91 98765 43210', email: 'priya@email.com',  orders: 28, spent: '₹14,200', wallet: '₹250', joined: 'Jan 2025', status: 'active'  },
  { id: 'U002', name: 'Rahul Gupta',   phone: '+91 87654 32109', email: 'rahul@email.com',  orders: 15, spent: '₹8,400',  wallet: '₹0',   joined: 'Feb 2025', status: 'active'  },
  { id: 'U003', name: 'Anjali Singh',  phone: '+91 76543 21098', email: 'anjali@email.com', orders: 42, spent: '₹21,800', wallet: '₹500', joined: 'Dec 2024', status: 'active'  },
  { id: 'U004', name: 'Vikram Nair',   phone: '+91 65432 10987', email: 'vikram@email.com', orders: 8,  spent: '₹3,200',  wallet: '₹0',   joined: 'Mar 2025', status: 'blocked' },
  { id: 'U005', name: 'Meera Pillai',  phone: '+91 54321 09876', email: 'meera@email.com',  orders: 31, spent: '₹16,400', wallet: '₹150', joined: 'Nov 2024', status: 'active'  },
  { id: 'U006', name: 'Amit Verma',    phone: '+91 43210 98765', email: 'amit@email.com',   orders: 19, spent: '₹9,800',  wallet: '₹75',  joined: 'Jan 2025', status: 'active'  },
];

export const DRIVERS = [
  { id: 'D001', name: 'Ramesh Kumar', phone: '+91 99887 76655', vehicle: 'MH01 AB 1234', trips: 342, rating: 4.8, earnings: '₹28,400', status: 'on_trip'   },
  { id: 'D002', name: 'Suresh Mishra',phone: '+91 88776 65544', vehicle: 'DL01 CD 5678', trips: 218, rating: 4.5, earnings: '₹19,200', status: 'available' },
  { id: 'D003', name: 'Javed Patel',  phone: '+91 77665 54433', vehicle: 'KA01 EF 9012', trips: 89,  rating: 3.9, earnings: '₹8,100',  status: 'offline'   },
  { id: 'D004', name: 'Pradeep Singh',phone: '+91 66554 43322', vehicle: 'MH02 GH 3456', trips: 412, rating: 4.7, earnings: '₹34,800', status: 'available' },
];

export const OFFERS = [
  { id: 'C001', code: 'WELCOME50', feature: 'All',     discount: '50%',   type: 'percent', minOrder: '₹99',  used: 1240, expires: 'Jul 20, 2026', status: 'active'  },
  { id: 'C002', code: 'MOVIE20',   feature: 'Movies',  discount: '20%',   type: 'percent', minOrder: '₹200', used: 432,  expires: 'Jul 5, 2026',  status: 'active'  },
  { id: 'C003', code: 'RIDE50',    feature: 'Rides',   discount: '₹50',   type: 'flat',    minOrder: '₹150', used: 289,  expires: 'Jun 30, 2026', status: 'active'  },
  { id: 'C004', code: 'HOTEL15',   feature: 'Hotels',  discount: '15%',   type: 'percent', minOrder: '₹2000',used: 98,   expires: 'Jul 15, 2026', status: 'active'  },
  { id: 'C005', code: 'MED30',     feature: 'Medicine',discount: '₹30',   type: 'flat',    minOrder: '₹100', used: 341,  expires: 'Jul 10, 2026', status: 'active'  },
  { id: 'C006', code: 'SUMMER25',  feature: 'All',     discount: '25%',   type: 'percent', minOrder: '₹300', used: 2100, expires: 'Jun 1, 2026',  status: 'expired' },
];

export const WALLET_TXN = [
  { id: 'TXN-88212', user: 'Priya S.',    feature: 'Food',   featureCls: 'badge-orange', amount: '₹842',   method: 'UPI',    date: 'Today 2:14pm', status: 'success'    },
  { id: 'TXN-88211', user: 'Vikram N.',   feature: 'Movie',  featureCls: 'badge-purple', amount: '₹780',   method: 'Card',   date: 'Today 1:42pm', status: 'success'    },
  { id: 'TXN-88210', user: 'Amit M.',     feature: 'Hotel',  featureCls: 'badge-teal',   amount: '₹24,000',method: 'UPI',    date: 'Today 12:18pm',status: 'processing' },
  { id: 'TXN-88209', user: 'Rahul G.',    feature: 'Rides',  featureCls: 'badge-warning',amount: '₹420',   method: 'Wallet', date: 'Today 11:00am',status: 'success'    },
  { id: 'TXN-88208', user: 'Anjali S.',   feature: 'Grocery',featureCls: 'badge-success',amount: '₹1,840', method: 'UPI',    date: 'Today 10:30am',status: 'success'    },
];

export const NOTIFICATIONS = [
  { id: 1, type: 'info',    title: 'New restaurant request',  body: 'Spice Garden, Pune applied for onboarding',          time: '5m ago',  read: false },
  { id: 2, type: 'warning', title: 'Driver offline — Mumbai', body: '12 drivers went offline in Mumbai zone',              time: '22m ago', read: false },
  { id: 3, type: 'danger',  title: 'Payment dispute',         body: 'Order #ORD-8802 — customer raised refund dispute',   time: '1h ago',  read: false },
  { id: 4, type: 'success', title: 'Revenue milestone! 🎉',   body: 'Monthly revenue crossed ₹12L target',                time: '3h ago',  read: true  },
];

export const SUPPORT_TICKETS = [
  { id: 'T001', user: 'Priya Sharma',  issue: 'Order cancelled but refund nahi aya',   feature: 'Food',   priority: 'urgent', time: '5m ago'  },
  { id: 'T002', user: 'Rahul Gupta',   issue: 'Driver ne galat jagah drop kiya',        feature: 'Rides',  priority: 'medium', time: '22m ago' },
  { id: 'T003', user: 'Anjali Singh',  issue: 'Movie ticket wrong show time',           feature: 'Movies', priority: 'low',    time: '1h ago'  },
];