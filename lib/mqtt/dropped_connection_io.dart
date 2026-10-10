import 'dart:io' show SocketException;

bool isDroppedConnection(Object error) => error is SocketException;
