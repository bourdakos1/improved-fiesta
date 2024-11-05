// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct Coordinate
{
    double latitude;
    double longitude;
};

struct Place
{
    char *name;
    struct Coordinate coordinate;
};

struct FileAttachmentDart
{
    char *file_name;
    char *mime_type;
    int64_t type;
    char *file_path;
    char *parent_folder;
    int64_t attachment_source_type;
    int32_t batch_id;
};

struct TextAttachmentDart
{
    int64_t type;
    char *text_title;
    char *text_body;
    char *mime_type;
    int64_t attachment_source_type;
    int32_t batch_id;
};

struct WifiCredentialsAttachmentDart
{
    char *ssid;
    int64_t security_type;
    char *password;
    uint8_t is_hidden;
    int64_t attachment_source_type;
    int32_t batch_id;
};

struct AttachmentsDart
{
    int64_t file_length;
    int64_t text_length;
    int64_t wifi_credentials_length;
    struct FileAttachmentDart** file_array;
    struct TextAttachmentDart** text_array;
    struct WifiCredentialsAttachmentDart** wifi_credentials_array;
};

struct Coordinate create_coordinate(double latitude, double longitude);
struct Place create_place(char *name, double latitude, double longitude);

double distance(struct Coordinate, struct Coordinate);

char *hello_world();
char *reverse(char *str, int length);

void send_attachments_dart(struct AttachmentsDart);
