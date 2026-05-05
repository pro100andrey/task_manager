import 'package:test/test.dart';
import 'package:tm_core/src/domain/value_objects/project/project_description.dart';
import 'package:tm_core/src/domain/value_objects/project/project_id.dart';
import 'package:tm_core/src/domain/value_objects/project/project_name.dart';
import 'package:tm_core/src/domain/value_objects/project/project_ref.dart';
import 'package:tm_core/src/domain/value_objects/task/task_description.dart';
import 'package:tm_core/src/domain/value_objects/task/task_id.dart';
import 'package:tm_core/src/domain/value_objects/task/task_title.dart';

void main() {
  group('ProjectId', () {
    test('accepts valid uuid', () {
      final id = ProjectId.generate();
      expect(id.value, isNotEmpty);
      expect(id.formatError, isNull);
    });

    test('rejects invalid uuid', () {
      expect(
        const ProjectId('not-a-uuid').formatError,
        contains('Invalid UUID format for ProjectId: not-a-uuid'),
      );
    });

    test('two generated ids are distinct', () {
      expect(ProjectId.generate(), isNot(equals(ProjectId.generate())));
    });
  });

  group('ProjectName', () {
    test('accepts non-empty string', () {
      expect(const ProjectName('Alpha'), 'Alpha');
    });

    test('rejects empty string', () {
      expect(
        const ProjectName('').cannotBeEmptyError,
        contains('ProjectName cannot be empty'),
      );
    });
  });

  group('ProjectDescription', () {
    test('accepts short description', () {
      expect(const ProjectDescription('desc'), 'desc');
    });

    test('rejects empty string', () {
      const desc = ProjectDescription('');
      expect(
        desc.cannotBeEmptyError,
        contains('ProjectDescription cannot be empty'),
      );

      expect(desc.cannotExceedMaxLengthError, isNull);
    });

    test('rejects string over 500 chars', () {
      final desc = ProjectDescription('x' * 501);

      expect(
        desc.cannotExceedMaxLengthError,
        contains('ProjectDescription cannot exceed 500 characters'),
      );

      expect(desc.cannotBeEmptyError, isNull);
    });

    test('accepts exactly 500 chars', () {
      expect(() => ProjectDescription('x' * 500), returnsNormally);
    });
  });

  group('ProjectRef', () {
    test('id ref carries maybeId, maybeName is null', () {
      final id = ProjectId.generate();
      final ref = ProjectRef.id(id);
      expect(ref.isId, isTrue);
      expect(ref, isA<ProjectIdRef>());
      expect(ref.isName, isFalse);
    });

    test('name ref carries maybeName, maybeId is null', () {
      const name = ProjectName('Beta');
      final ref = ProjectRef.name(name);
      expect(ref.isName, isTrue);
      expect(ref, isA<ProjectNameRef>());
      expect(ref.isId, isFalse);
    });

    test('value returns raw string for both types', () {
      final id = ProjectId.generate();
      expect(ProjectRef.id(id).value, id.value);
      expect(ProjectRef.name(const ProjectName('X')).value, 'X');
    });
  });

  group('TaskId', () {
    test('accepts valid uuid', () {
      expect(TaskId.generate, returnsNormally);
    });

    test('rejects invalid uuid', () {
      expect(() => TaskId('bad'), throwsFormatException);
    });
  });

  group('TaskTitle', () {
    test('accepts valid title', () {
      expect(TaskTitle('Do something').raw, 'Do something');
    });

    test('rejects empty title', () {
      expect(() => TaskTitle(''), throwsArgumentError);
    });
  });

  group('TaskDescription', () {
    test('accepts short description', () {
      expect(TaskDescription('details').raw, 'details');
    });

    test('rejects empty', () {
      expect(() => TaskDescription(''), throwsArgumentError);
    });

    test('rejects over 500 chars', () {
      expect(() => TaskDescription('y' * 501), throwsArgumentError);
    });
  });
}
