import 'package:chofair_user/models/direction_details_info.dart';
import 'package:chofair_user/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

List dList = []; //online-active driversKey info List

  DirectionDetailsInfo? tripDirectionDetailsInfo;