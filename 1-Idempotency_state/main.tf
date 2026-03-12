resource "local_file" "server1" {
  content  = "im server 1!"
  filename = "${path.module}/result/server1.foo"
}

resource "local_file" "server2" {
  content  = "im server 2!"
  filename = "${path.module}/result/server2.foo"
}

resource "local_file" "server3" {
  content  = "im server 3!"
  filename = "${path.module}/result/server3.foo"
}