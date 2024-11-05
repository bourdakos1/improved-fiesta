// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io' show Directory, Platform;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// Example of handling a simple C struct
final class Coordinate extends Struct {
  @Double()
  external double latitude;

  @Double()
  external double longitude;
}

// Example of a complex struct (contains a string and a nested struct)
final class Place extends Struct {
  external Pointer<Utf8> name;

  external Coordinate coordinate;
}

final class FileAttachment extends Struct {
  external Pointer<Utf8> fileName;
  external Pointer<Utf8> mimeType;
  @Int64()
  external int type;
  external Pointer<Utf8> filePath;
  external Pointer<Utf8> parentFolder;
  @Int64()
  external int attachmentSourceType;
  @Int32()
  external int batchId;
}

final class TextAttachment extends Struct {
  @Int64()
  external int type;
  external Pointer<Utf8> textTitle;
  external Pointer<Utf8> textBody;
  external Pointer<Utf8> mimeType;
  @Int64()
  external int attachmentSourceType;
  @Int32()
  external int batchId;
}

final class WifiCredentialsAttachment extends Struct {
  external Pointer<Utf8> ssid;
  @Int64()
  external int securityType;
  external Pointer<Utf8> password;
  @Bool()
  external bool isHidden;
  @Int64()
  external int attachmentSourceType;
  @Int32()
  external int batchId;
}

final class Attachments extends Struct {
  @Int64()
  external int fileLength;
  @Int64()
  external int textLength;
  @Int64()
  external int wifiCredentialsLength;
  external Pointer<Pointer<FileAttachment>> fileArray;
  external Pointer<Pointer<TextAttachment>> textArray;
  external Pointer<Pointer<WifiCredentialsAttachment>> wifiCredentialsArray;
}

// C function: char *hello_world();
// There's no need for two typedefs here, as both the
// C and Dart functions have the same signature
typedef HelloWorld = Pointer<Utf8> Function();

// C function: char *reverse(char *str, int length)
typedef ReverseNative = Pointer<Utf8> Function(Pointer<Utf8> str, Int32 length);
typedef Reverse = Pointer<Utf8> Function(Pointer<Utf8> str, int length);

// C function: void free_string(char *str)
typedef FreeStringNative = Void Function(Pointer<Utf8> str);
typedef FreeString = void Function(Pointer<Utf8> str);

// C function: struct Coordinate create_coordinate(double latitude, double longitude)
typedef CreateCoordinateNative = Coordinate Function(
    Double latitude, Double longitude);
typedef CreateCoordinate = Coordinate Function(
    double latitude, double longitude);

// C function: struct Place create_place(char *name, double latitude, double longitude)
typedef CreatePlaceNative = Place Function(
    Pointer<Utf8> name, Double latitude, Double longitude);
typedef CreatePlace = Place Function(
    Pointer<Utf8> name, double latitude, double longitude);

typedef DistanceNative = Double Function(Coordinate p1, Coordinate p2);
typedef Distance = double Function(Coordinate p1, Coordinate p2);

// C function: void free_string(char *str)
typedef SendAttachmentsNative = Void Function(Attachments a);
typedef SendAttachments = void Function(Attachments a);

void main() {
  // Open the dynamic library
  var libraryPath =
      path.join(Directory.current.path, 'structs_library', 'libstructs.so');
  if (Platform.isMacOS) {
    libraryPath = path.join(
        Directory.current.path, 'structs_library', 'libstructs.dylib');
  }
  if (Platform.isWindows) {
    libraryPath = path.join(
        Directory.current.path, 'structs_library', 'Debug', 'structs.dll');
  }
  final dylib = DynamicLibrary.open(libraryPath);

  final helloWorld =
      dylib.lookupFunction<HelloWorld, HelloWorld>('hello_world');
  final message = helloWorld().toDartString();
  print(message);

  final reverse = dylib.lookupFunction<ReverseNative, Reverse>('reverse');
  final backwards = 'backwards';
  final backwardsUtf8 = backwards.toNativeUtf8();
  final reversedMessageUtf8 = reverse(backwardsUtf8, backwards.length);
  final reversedMessage = reversedMessageUtf8.toDartString();
  calloc.free(backwardsUtf8);
  print('$backwards reversed is $reversedMessage');

  final freeString =
      dylib.lookupFunction<FreeStringNative, FreeString>('free_string');
  freeString(reversedMessageUtf8);

  final createCoordinate =
      dylib.lookupFunction<CreateCoordinateNative, CreateCoordinate>(
          'create_coordinate');
  final coordinate = createCoordinate(3.5, 4.6);
  print(
      'Coordinate is lat ${coordinate.latitude}, long ${coordinate.longitude}');

  final myHomeUtf8 = 'My Home'.toNativeUtf8();
  final createPlace =
      dylib.lookupFunction<CreatePlaceNative, CreatePlace>('create_place');
  final place = createPlace(myHomeUtf8, 42.0, 24.0);
  final name = place.name.toDartString();
  calloc.free(myHomeUtf8);
  final coord = place.coordinate;
  print(
      'The name of my place is $name at ${coord.latitude}, ${coord.longitude}');
  final distance = dylib.lookupFunction<DistanceNative, Distance>('distance');
  final dist = distance(createCoordinate(2.0, 2.0), createCoordinate(5.0, 6.0));
  print("distance between (2,2) and (5,6) = $dist");

  final attachmentList = calloc<Attachments>();
  attachmentList.ref.fileLength = 1;
  attachmentList.ref.textLength = 0;
  attachmentList.ref.wifiCredentialsLength = 0;
  attachmentList.ref.fileArray = calloc(1 * sizeOf<FileAttachment>());
  attachmentList.ref.textArray = calloc(0);
  attachmentList.ref.wifiCredentialsArray = calloc(0);

  attachmentList.ref.fileArray[0] = calloc<FileAttachment>()
    ..ref.filePath = "niko".toNativeUtf8(allocator: calloc);
  
  final sendAttachments =
      dylib.lookupFunction<SendAttachmentsNative, SendAttachments>('send_attachments_dart');
  sendAttachments(attachmentList.ref);
}
