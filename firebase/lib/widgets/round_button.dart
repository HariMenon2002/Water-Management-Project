import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;

  const RoundButton({Key?key,required this.title,required this.onTap,this.loading=false}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height:50,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: loading ? const CircularProgressIndicator(strokeWidth: 3,color:Colors.white):Text(title, style: const TextStyle(color: Colors.white),),),
      ),
    );
  }
}

class Contain extends StatelessWidget {

  final String title;
  final Color  color;
  final String message;
  final String max;

  const Contain({super.key,required this.message,required this.color,required this.title,this.max=""});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height:100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10)
      ),
      child:Column(mainAxisAlignment:MainAxisAlignment.center,children: [Center(child: Text(title)),Text(message),Text("Max:$max")]),
    );
  }
}

