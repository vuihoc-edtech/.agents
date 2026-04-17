# Flutter Skills

Bộ skill này dùng để chuẩn hóa kiến trúc, design system, localization, deeplink, storage, bootstrap, và các convention cho Flutter project.

## Cách dùng với `git submodule`

Trong Flutter project, thêm repo này dưới thư mục `.agents`:

```bash
git submodule add git@github.com:hautvfami/.agents.git .agents
```

Sau đó khởi tạo và cập nhật submodule:

```bash
git submodule update --init --recursive
```

Nếu clone project mới có submodule sẵn:

```bash
git clone --recurse-submodules <your-flutter-project-git>
```

Hoặc nếu đã clone rồi:

```bash
git submodule update --init --recursive
```

## Cập nhật bộ skill

Vào thư mục submodule rồi pull:

```bash
cd .agents
git pull origin main
```

Quay lại Flutter project và commit phần thay đổi ref của submodule:

```bash
cd ..
git add .agents
git commit -m "chore: update flutter skills submodule"
```

## Cấu trúc khuyến nghị

```text
your_flutter_project/
  .agents/
  lib/
  pubspec.yaml
```

## Gợi ý sử dụng

- dùng repo này như nguồn rule và skill dùng chung cho nhiều Flutter project
- giữ `.agents` ở root project để dễ quản lý
- khi cần đồng bộ rule mới, chỉ cần update submodule
