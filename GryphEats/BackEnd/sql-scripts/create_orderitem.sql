create table orderitem (orderid int, foodid int, identifier int auto_increment, primary key (identifier), foreign key (orderid) references foodorder(orderid), foreign key (foodid) references food(foodid));
