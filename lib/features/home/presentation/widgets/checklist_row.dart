import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistRow extends StatelessWidget {
  const ChecklistRow({super.key, required this.raw, required this.onTap});

  final String raw;
  final void Function(bool checked) onTap;

  @override
  Widget build(BuildContext context) {
    final checked = raw.startsWith('[x]');
    final label = raw.replaceFirst(RegExp(r'^\[([ x])\]\s?'), '');

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTap(!checked),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: checked
                    ? const Color(0xFF18A957)
                    : const Color(0xFFD0D0D0),
                width: 1.4,
              ),
              color: checked ? const Color(0xFFE6F6EC) : Colors.transparent,
            ),
            child: checked
                ? Center(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF18A957),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 16 / 14,
                letterSpacing: 0,
                color: const Color(0xFF4D4D4D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
