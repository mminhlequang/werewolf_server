import '../werewolf_server.dart';

final List<Language> LANGUAGES = [
  Language(name: "VN", code: "vi", id: 1),
  Language(name: "US", code: "en", id: 2),
];

final List<Sectarian> SECTARIANS = [
  Sectarian(name: "Dân làng", languageId: 1, id: 1),
  Sectarian(name: "Ma sói", languageId: 1, id: 2),
  Sectarian(name: "Đơn độc", languageId: 1, id: 3),
];

final List<Role> ROLES_CLASSIC = [
  Role(
      name: "Bác sĩ",
      description:
          "Chọn một người chơi để che chở vào mỗi đêm. Người chơi đó sẽ không bị giết vào đêm đó.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Xạ thủ",
      description:
          "Bạn có hai viên đạn mà bạn có thể sử dụng để bắn ai đó. Chỉ được bắn một viên đạn mỗi ngày. "
          "Vì âm thanh khi bắn rất lớn vậy nên vai trì của bạn sẽ bị được tiết lộ sau lần bắn đầu tiên. Bạn không thể bắn trong gia đoạn thảo luận vào ngày đầu tiên.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Tiên tri",
      description: "Mỗi đêm bạn có thể xem vai trò của người khác",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Thầy bói",
      description:
          "Mỗi đêm bạn có thể bói một người để biết họ thuộc phe thiện hay ác hoặc không rõ."
          "\nNhững mục tiêu không rõ có thể là: Xạ thủ, Thầy đồng, Phù Thuỷ, Sói Đầu Đàn, Thằng ngố, Thợ Săn Người hoặc Kẻ Ăn Thịt Người.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Thám Tử",
      description:
          "Mỗi đêm, bạn có thể chọn hai người chơi để khám phá và biết được họ ở cùng một phe hay là khác phe. "
          "Các phe có thể là dân làng, ma sói, thằng ngố, thợ săn người, sát nhân hàng loạt,...",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Thầy Đồng",
      description:
          "Vào ban đêm bạn có thể nói chuyện ẩn danh với người chết. Bạn có một lần hồi sinh người khác.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Phù Thuỷ",
      description:
          "Bạn có hai bình thuốc: Một bình dùng để giết và bình kia để bảo vệ người chơi. "
          "Bình bảo vệ chỉ được tiêu thụ nếu người chơi đó bị tấn công. Bạn không thể giết trong đêm đầu tiên.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Kẻ Báo Thù",
      description: "Bạn có thể chọn một người chơi để báo thù khi bạn chết.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Thần Tình Yêu",
      description:
          "Trong đêm đầu tiên bạn có thể chọn hai người chơi để họ làm tình nhân của nhau. "
          "Bạn thắng nếu phe dân làng thắng hoặc cặp tình nhân là những người cuối cùng sống sót.",
      languageId: 1,
      sectarians: [1],
      type: RoleType.classic),
  Role(
      name: "Bán Sói",
      description:
          "Bạn là dân làng bình thường cho tới khi bạn bị sói cắn, lúc đó bạn sẽ trở thành ma sói. "
          "Bạn không thể bị biến đổi qua phe khác bởi Giáo chủ...",
      languageId: 1,
      sectarians: [1, 2],
      type: RoleType.classic),
  Role(
      name: "Ma Sói",
      description: "Chọn một người để giết mỗi đêm.",
      languageId: 1,
      sectarians: [2],
      type: RoleType.classic),
  Role(
      name: "Ma Sói",
      description: "Chọn một người để giết mỗi đêm.",
      languageId: 1,
      sectarians: [2],
      type: RoleType.classic),
  Role(
      name: "Sói Pháp Sư",
      description:
          "Trong ngày bạn có thể yểm người chơi khác. Đối với các Tiên Tri, Thầy Bói,... "
          "người chơi này sẽ được soi thành một Sói Pháp Sư(Hoặc Ác) vào đêm hôm sau. Nếu bạn là ma sói cuối cùng, bạn không thể yểm bất cứ ai.",
      languageId: 1,
      sectarians: [2],
      type: RoleType.classic),
  Role(
      name: "Sói Đầu Đàn",
      description:
          "Bạn là Ma Sói bình thường, ngoại trừ việc bạn có phiếu bầu gấp đôi trong đêm và Thầy Bói sẽ không thấy rõ bạn.",
      languageId: 1,
      sectarians: [2],
      type: RoleType.classic),
  Role(
      name: "Sói Tiên Tri",
      description:
          "Mỗi đêm, bạn có thể chọn một người chơi để xem vai trò của hắn ta. "
          "Nếu bạn là ma sói cuối cùng hoặc bạn từ bỏ khả năng của mình, bạn sẽ trở thành ma sói bình thường.",
      languageId: 1,
      sectarians: [2],
      type: RoleType.classic),
  Role(
      name: "Thợ Săn Người",
      description:
          "Mục đích của bạn là làm cho mục tiêu của bạn bị treo cổ bởi dân làng vào ban ngày. "
          "Mục tiêu phải được treo cổ trước khi bạn chết để giành chiến thắng. "
          "Nếu mục tiêu của bạn chết theo cách khác, bạn trở thành một dân làng bình thường.",
      languageId: 1,
      sectarians: [1, 3],
      type: RoleType.classic),
  Role(
      name: "Thằng Ngố",
      description:
          "Bạn phải lừa dân làng treo cổ bạn. Nếu họ treo cổ bạn, bạn thắng.",
      languageId: 1,
      sectarians: [3],
      type: RoleType.classic),
  Role(
      name: "Kẻ Ăn Thịt Người",
      description:
          "Mỗi đêm bạn có thể giết một người chơi bằng cách nuốt chửng hắn ta hoặc nhịn cơn đói của mình để ăn tối đa năm người chơi trong một đêm."
          "\nBạn không thể bị giết bởi ma sói.\nBạn thắng nếu bạn là người chơi cuối cùng.",
      languageId: 1,
      sectarians: [3],
      type: RoleType.classic),
];
